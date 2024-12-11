//
//  StructuralSections.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 12/10/2024.
// 	Some of this code is based on CUFSM, and is noted as such.
//

import SwiftUI
import Spatial

protocol SSection: Codable {
	/// Centroid of section, relative to input coordinates
	var centroid: SIMD2<Double> { get }
	/// Shear Center of Section, relative to input coordinates
	var shearCenter: SIMD2<Double> { get }
	/// Area of section
	var A: Double { get }
	/// Moment of Inertia about X-Axis
	var Ixx: Double { get }
	/// Moment of Inertia about Y-Axis
	var Iyy: Double { get }
	/// Product of Inertia
	var Ixy: Double { get }
	/// Principle Moment of Inertia about Major Axis
	var IX: Double { get }
	/// Principle Moment of Inertia about Minor Axis
	var IY: Double { get }
	/// Polar Moment of Inertia
	var Iz: Double { get }
	/// Angle Between Geometric and Principle Axes
	var theta: Angle2D { get }
	
	/// Radius of Gyration about X-Axis
	var rxx: Double { get }
	/// Radius of Gyration about Y-Axis
	var ryy: Double { get }
	/// Polar Radius of Gyration
	var ro: Double { get }
	
	/// Elastic Section Modulus about X-Axis
	var Sxx: Double { get }
	/// Elastic Section Modulus about Y-Axis
	var Syy: Double { get }
	
	/// Plastic Section Modulus about X-Axis
	//var Zxx: Double { get }
	/// Plastic Section Modulus about Y-Axis
	//var Zyy: Double { get }
	
	var sectionType: AnySSection.SSectionType { get }
}
extension SSection {
	var rxx: Double { sqrt(Ixx/A) }
	var ryy: Double { sqrt(Iyy/A) }
	var ro: Double { sqrt(Iz/A + pow(shearCenter.x-centroid.x,2) + pow(shearCenter.y-centroid.y,2)) }
	var Iz: Double { IX+IY }
	var IX: Double { (Ixx+Iyy)/2+sqrt(pow(Ixx-Iyy,2)+4*pow(Ixy,2))/2 }
	var IY: Double { (Ixx+Iyy)/2-sqrt(pow(Ixx-Iyy,2)+4*pow(Ixy,2))/2 }
	var theta: Angle2D { .radians(atan(-2*Ixy/(Ixx-Iyy))/2) }
}
/// A thin-walled section, no branches & not closed
struct SSectionCFS: SSection, Identifiable, Hashable {
	private(set) var sectionType: AnySSection.SSectionType = .CFS
	let id: UUID
	init(straightSubsections: [StraightLineElement] = [], circleArcSubsections: [CircleArcLineElement] = []) {
		self.straightElements = straightSubsections
		self.circleArcElements = circleArcSubsections
		id = UUID()
		
		Iwx = 0.0
		Iwy = 0.0
		wno = 0.0
		w = [:]
		wo = [:]
		r = [:]
		rCircles = [:]
		self.updateSectionProperties()
	}
	
	var A: Double {
		elements.map(\.A).reduce(0, +)
	}
	var xMax: Double {
		var result: Double = 0
		for s in elements {
			result = max(result, s.node1.x, s.node2.x)
		}
		return result
	}
	var xMin: Double {
		var result: Double = 0
		for s in elements {
			result = min(result, s.node1.x, s.node2.x)
		}
		return result
	}
	var yMax: Double {
		var result: Double = 0
		for s in elements {
			result = max(result, s.node1.y, s.node2.y)
		}
		return result
	}
	var yMin: Double {
		var result: Double = 0
		for s in elements {
			result = min(result, s.node1.y, s.node2.y)
		}
		return result
	}
	
	/// Centroid
	var centroid: SIMD2<Double> {
		let sigmaAx: Double = elements.map({$0.A*$0.centroid.x}).reduce(0, +)
		let sigmaAy: Double = elements.map({$0.A*$0.centroid.y}).reduce(0, +)
		let xc = (sigmaAx/A).zeroIfClose
		let yc = (sigmaAy/A).zeroIfClose
		return SIMD2(x: xc, y: yc)
	}
	
	var Ixx: Double {
		let centroid = centroid
		return elements.map({$0.Ixx + $0.A*pow(($0.centroid.y-centroid.y).zeroIfClose,2)}).reduce(0, +)
	}
	var Iyy: Double {
		let centroid = centroid
		return elements.map({$0.Iyy + $0.A*pow(($0.centroid.x-centroid.x).zeroIfClose,2)}).reduce(0, +)
	}
	var Ixy: Double {
		let centroid = centroid
		let Ixy = elements.map({$0.Ixy + $0.A*($0.centroid.x-centroid.x).zeroIfClose*($0.centroid.y-centroid.y).zeroIfClose}).reduce(0, +)
		return Ixy.isApproxEqual(to: 0) ? 0:Ixy
	}
	private(set) var Iwx: Double
	private(set) var Iwy: Double
//	var Iw: Double {
//		return 0
//	}
	var Sxx: Double {
		let c = max(abs(yMax-centroid.y),abs(centroid.y-yMin))
		return Ixx / (c+elements.max(by: {$0.t < $1.t})!.t/2)
	}
	var Syy: Double {
		let c = max(abs(xMax-centroid.x),abs(centroid.x-xMin))
		return Iyy / (c+elements.max(by: {$0.t < $1.t})!.t/2)
	}
//	var Zxx: Double {
//
//	}
//	var Zyy: Double {
//
//	}
	var J: Double {
		let loops = findClosedLoops(lineSegments: elements)
		if loops.isEmpty {
			// Open section
			return elements.map(\.J).reduce(0, +)
		} else {
			// CUFSM method (not used):
//			% compute the torsional constant for close-section
//			   for i = 1:nele
//				   sn = ends(i,1); fn = ends(i,2);
//				   p(i) = ((coord(sn,1)-xc)*(coord(fn,2)-yc)-(coord(fn,1)-xc)*(coord(sn,2)-yc))/L(i);
//			   end
//			   J = 4*sum(p.*L/2)^2/sum(L./t);
			
			// Closed Section - This may be incorrect.
			let areasX2: [Double] = loops.map { nodes in
				guard nodes.count > 2 else { return 0 } // A polygon must have at least 3 vertices
				
				var area: Double = 0
				let count = nodes.count
				
				for i in 0..<count {
					let current = nodes[i]
					let next = nodes[(i + 1) % count] // Wrap around to the first node
					area += (current.x * next.y) - (current.y * next.x)
				}
				return abs(area)
			}
			
			var totalJ: Double = 0
			for i in 0..<loops.count {
				let cell = loops[i]
				var perimeterTerm: CGFloat = 0
				for j in 0..<cell.count {
					let current = cell[j]
					let next = cell[(j + 1) % cell.count] // Wrap around
					let length = hypot(next.x - current.x, next.y - current.y)
					let thickness = elements.first(where: {
						$0.node1.isApproxEqual(to: current) && $0.node2.isApproxEqual(to: next) ||
						$0.node2.isApproxEqual(to: current) && $0.node1.isApproxEqual(to: next)
					})?.t ?? 0
					perimeterTerm += length / thickness
				}
				totalJ += pow(areasX2[i], 2) / perimeterTerm
			}
			return totalJ
		}
	}
	private(set) var r: [StraightLineElement: Double]
	private(set) var rCircles: [CircleArcLineElement: Double]
	private(set) var w: [Node: Double]
	private(set) var wo: [Node: Double]
	private(set) var wno: Double = 0
	var warpingMax: Double {
		let node = nodes.max { n1, n2 in
			abs(warpingNormal(for: n1)) < abs(warpingNormal(for: n2))
		}!
		return warpingNormal(for: node)
	}
	/// Normalized Warping Function
	func warpingNormal(for node: Node)->Double {
		return wno - (wo[node] ?? 0)
	}
	var warpingInfo: String {
		var str = ""
		for node in nodes.sorted(by: {$0.x < $1.x}) {
			str = str + node.description + ": \(warpingNormal(for: node))\n"
		}
		return str
	}
	var warpingInfo2: String {
		var str = ""
		for node in nodes.sorted(by: {$0.x < $1.x}) {
			str = str + node.description + ": \(w[node] ?? Double.nan)\n"
		}
		return str
	}
	var elementInfo: String {
		var str = ""
		for element in elements {
			if let element = element as? StraightLineElement {
				str = str + "node1:\(element.node1.id), node2: \(element.node2.id), centroid: (\(element.centroid.x.formatted(numFractionDigits: 3)),\(element.centroid.y.formatted(numFractionDigits: 3))), t: \(element.t), length: \(element.length.formatted(numFractionDigits: 3))\n"
			}
			if let element = element as? CircleArcLineElement {
				str = str + "node1:\(element.node1.id), node2: \(element.node2.id), centroid: (\(element.centroid.x.formatted(numFractionDigits: 3)),\(element.centroid.y.formatted(numFractionDigits: 3))), radius: \(element.radius.formatted(numFractionDigits: 3)), t: \(element.t), length: \(element.length.formatted(numFractionDigits: 3))\n"
			}
		}
		str = str + "\n"
		let sigmaAx: Double = elements.map({$0.A*$0.centroid.x}).reduce(0, +)
		let sigmaAy: Double = elements.map({$0.A*$0.centroid.y}).reduce(0, +)
		str = str + "sigmaAx: \(sigmaAx)\n"
		str = str + "sigmaAy: \(sigmaAy)\n"
		return str
	}
	/// Warping Torsion Constant
	var Cw: Double {
		if isClosedSection { return 0 }
		//let x = Iw + (Iwx*(Iwy*Ixy-Iwx*Ixx)+Iwy*(Iwx*Ixy-Iwy*Iyy))/(Ixx*Iyy+pow(Ixy,2))
		//print("Cw v1 = \(x)")
		var Cw: Double = 0
		for element in elements {
			// From CUFSM
			Cw = Cw + (1/3)*(warpingNormal(for: element.node1)**2+warpingNormal(for: element.node1)*warpingNormal(for: element.node2)+warpingNormal(for: element.node2)**2)*element.A;
		}
		//print("Cw v2 = \(Cw)")
		return Cw
	}
	/// Shear Center
	var shearCenter: SIMD2<Double> {
		if isClosedSection { return SIMD2(Double.nan, Double.nan) }
		let Ixy = Ixy
		let Ixx = Ixx
		let Iyy = Iyy
		let centroid = centroid
		if (Ixx*Iyy-Ixy*Ixy).isApproxEqual(to: 0) {
			return centroid
		} else {
			var xS = (Iyy*Iwy-Ixy*Iwx)/(Ixx*Iyy-Ixy*Ixy) + centroid.x
			var yS = -(Ixx*Iwx-Ixy*Iwy)/(Ixx*Iyy-Ixy*Ixy) + centroid.y
			if xS.isApproxEqual(to: 0) { xS = 0 }
			if yS.isApproxEqual(to: 0) { yS = 0 }
			return SIMD2(xS, yS)
		}
	}
	var nodes: Set<Node> {
		var nodes = Set<Node>()
		for s in elements {
			nodes.insert(s.node1)
			nodes.insert(s.node2)
		}
		return nodes
	}
	var nodeCounts: [Node:Int] {
		var nodeCounts: [Node: Int] = [:]
		for i in elements {
			if nodeCounts.contains(where: { i.node1.isApproxEqual(to: $0.key) }) {
				if nodeCounts[i.node1] != nil {
					nodeCounts[i.node1]! += 1
				} else {
					if let node = nodeCounts.first(where: {i.node1.isApproxEqual(to: $0.key)}) {
						nodeCounts[node.key]? += 1
					}
				}
			} else {
				nodeCounts[i.node1] = 1
			}
			if nodeCounts.contains(where: { i.node2.isApproxEqual(to: $0.key) }) {
				if nodeCounts[i.node2] != nil {
					nodeCounts[i.node2]! += 1
				} else {
					if let node = nodeCounts.first(where: {i.node2.isApproxEqual(to: $0.key)}) {
						nodeCounts[node.key]? += 1
					}
				}
			} else {
				nodeCounts[i.node2] = 1
			}
		}
		return nodeCounts
	}
	var nodesWith1ConnectedElement: [Node] { Array(nodeCounts.filter({ $0.value == 1 }).keys) }
	var nodesWith2ConnectedElements: [Node] { Array(nodeCounts.filter({ $0.value == 2 }).keys) }
	var isClosedSection: Bool {
		return nodes.count < elements.count
//		if nodesWith2ConnectedElements.count == elements.count { return true }
//		if !findClosedLoops(lineSegments: elements).isEmpty { return true }
//		return false
	}
	func findClosedLoops(lineSegments: [any LineElement]) -> [[Node]] {
		// Step 1: Build the adjacency list
		var adjacencyList: [Node: [Node]] = [:]
		for segment in lineSegments {
			adjacencyList[segment.node1, default: []].append(segment.node2)
			adjacencyList[segment.node2, default: []].append(segment.node1)
		}
		
		// Step 2: Helper function for DFS traversal
		func dfs(current: Node, start: Node, path: [Node], visitedEdges: inout Set<Set<Node>>, loops: inout [[Node]]) {
			for neighbor in adjacencyList[current, default: []] {
				let edge = Set([current, neighbor]) // Use a set to represent an edge
				if !visitedEdges.contains(edge) {
					visitedEdges.insert(edge) // Mark edge as visited
					let newPath = path + [neighbor]
					
					if neighbor == start && newPath.count > 2 {
						// Found a closed loop
						loops.append(newPath)
					} else if !path.contains(neighbor) {
						// Continue DFS
						dfs(current: neighbor, start: start, path: newPath, visitedEdges: &visitedEdges, loops: &loops)
					}
				}
			}
		}
		
		// Step 3: Find all closed loops
		var visitedEdges: Set<Set<Node>> = []
		var loops: [[Node]] = []
		
		for segment in lineSegments {
			let start = segment.node1
			let end = segment.node2
			let edge = Set([start, end])
			if !visitedEdges.contains(edge) {
				visitedEdges.insert(edge)
				dfs(current: end, start: start, path: [start, end], visitedEdges: &visitedEdges, loops: &loops)
			}
		}
		
		// Step 4: Normalize and filter loops (remove duplicates)
		let uniqueLoops = Set(loops.map { loop in
			// Normalize by sorting nodes in the loop and treating it as a cycle
			let start = loop.min { a, b in
				a < b
			}!
			let startIndex = loop.firstIndex(of: start)!
			let normalizedLoop = loop[startIndex...] + loop[..<startIndex]
			return Array(normalizedLoop)
		})
		
		return Array(uniqueLoops)
	}
	mutating func moveNode(_ node: Node, to newNode: Node) {
		func updatingList(_ list: inout [some LineElement]) {
			for i in list.indices {
				if list[i].node1.isApproxEqual(to: node) {
					list[i] = list[i].updateNode1(to: newNode)
				}
				if list[i].node2.isApproxEqual(to: node) {
					list[i] = list[i].updateNode2(to: newNode)
				}
			}
		}
		updatingList(&straightElements)
		updatingList(&circleArcElements)
		updateSectionProperties()
	}
	var elements: [any LineElement] {
		straightElements + circleArcElements
	}
	var straightElements: [StraightLineElement]
	var circleArcElements: [CircleArcLineElement]
	mutating func updateSectionProperties() {
		if isClosedSection {
			return
		}
		// Compute Warping Properties
		// From CUFSM
		//		% compute the shear center and initialize variables
		//		   nnode = size(coord,1);
		//		   w = zeros(nnode,2); w(ends(1,1),1) = ends(1,1);
		//		   wo = zeros(nnode,2); wo(ends(1,1),1) = ends(1,1);
		//		   Iwx = 0; Iwy = 0; wno = 0; Cw = 0;
		//		for j = 1:nele
		//			   i = 1;
		//			   while (any(w(:,1)==ends(i,1))&any(w(:,1)==ends(i,2)))|(~(any(w(:,1)==ends(i,1)))&(~any(w(:,1)==ends(i,2))))
		//				   i = i+1;
		//			   end
		//			   sn = ends(i,1); fn = ends(i,2);
		//			   p = ((coord(sn,1)-xc)*(coord(fn,2)-yc)-(coord(fn,1)-xc)*(coord(sn,2)-yc))/L(i);
		//			   if w(sn,1)==0
		//				   w(sn,1) = sn;
		//				   w(sn,2) = w(fn,2)-p*L(i);
		//			   elseif w(fn,1)==0
		//				   w(fn,1) = fn;
		//				   w(fn,2) = w(sn,2)+p*L(i);
		//		end
		var Iwx = 0.0
		var Iwy = 0.0
		var wno = 0.0
		let centroid = centroid
		
		var w: [Node: Double] = [:]
		var wo: [Node: Double] = [:]
		var wProcessed: [Node: Bool] = [:]
		for i in circleArcElements.indices {
			if circleArcElements[i].node1.x.isNaN {
				circleArcElements[i].node1.x = 0
				print("bad node")
			}
			if circleArcElements[i].node1.y.isNaN {
				circleArcElements[i].node1.y = 0
				print("bad node")
			}
			if circleArcElements[i].node2.x.isNaN {
				circleArcElements[i].node2.x = 0
				print("bad node")
			}
			if circleArcElements[i].node2.y.isNaN {
				circleArcElements[i].node2.y = 0
				print("bad node")
			}
		}
		for i in straightElements.indices {
			if straightElements[i].node1.x.isNaN {
				straightElements[i].node1.x = 0
				print("bad node")
			}
			if straightElements[i].node1.y.isNaN {
				straightElements[i].node1.y = 0
				print("bad node")
			}
			if straightElements[i].node2.x.isNaN {
				straightElements[i].node2.x = 0
				print("bad node")
			}
			if straightElements[i].node2.y.isNaN {
				straightElements[i].node2.y = 0
				print("bad node")
			}
		}
		for n in nodes {
			w[n] = 0
			wo[n] = 0
			wProcessed[n] = false
		}
		wProcessed[nodesWith1ConnectedElement.first!] = true
		for _ in elements {
			guard let elementToProcess = elements.first(where: {
				(wProcessed[$0.node1] == true || wProcessed[$0.node2] == true) && wProcessed[$0.node1] != wProcessed[$0.node2]
			}) else { fatalError() }
			
			let sn = elementToProcess.node1
			let fn = elementToProcess.node2
			let t = elementToProcess.t
			let L = elementToProcess.length
			
			// Calculate `ρ` based on the element geometry
			let r = ((sn.x - centroid.x) * (fn.y - centroid.y) -
					 (fn.x - centroid.x) * (sn.y - centroid.y)) / L
			
			if let elementToProcess = elementToProcess as? StraightLineElement {
				self.r[elementToProcess] = r
			} else if let elementToProcess = elementToProcess as? CircleArcLineElement{
				rCircles[elementToProcess] = r
			}
			
			// Update the `w` dictionary
			if wProcessed[sn] == false  {
				w[sn] = (w[fn] ?? 0) - r*L
				wProcessed[sn] = true
			} else if wProcessed[fn] == false  {
				w[fn] = (w[sn] ?? 0) + r*L
				wProcessed[fn] = true
			}
			
			// 	From CUFSM
			// 	Iwx = Iwx+(1/3*(w(sn,2)*(coord(sn,1)-xc)+w(fn,2)*(coord(fn,1)-xc))+1/6*(w(sn,2)*(coord(fn,1)-xc)+w(fn,2)*(coord(sn,1)-xc)))*t(i)* L(i);
			//  Iwy = Iwy+(1/3*(w(sn,2)*(coord(sn,2)-yc)+w(fn,2)*(coord(fn,2)-yc))+1/6*(w(sn,2)*(coord(fn,2)-yc)+w(fn,2)*(coord(sn,2)-yc)))*t(i)* L(i);
			let wsn = (w[sn] ?? 0)
			let wfn = (w[fn] ?? 0)
			
			Iwx += (1.0/3.0 * (wsn * (sn.x - centroid.x) + wfn * (fn.x - centroid.x)) +
					1.0/6.0 * (wsn * (fn.x - centroid.x) + wfn * (sn.x - centroid.x))) * t * L
			
			Iwy += (1.0/3.0 * (wsn * (sn.y - centroid.y) + wfn * (fn.y - centroid.y)) +
					1.0/6.0 * (wsn * (fn.y - centroid.y) + wfn * (sn.y - centroid.y))) * t * L
		}
		self.Iwx = Iwx.zeroIfClose
		self.Iwy = Iwy.zeroIfClose
		let shearCenter = shearCenter
		// Shear center can now be calculated - Not implemented within this function.
//		shearCenter = {
//			if isClosedSection { return SIMD2(Double.nan, Double.nan) }
//			let Ixy = Ixy
//			let Ixx = Ixx
//			let Iyy = Iyy
//			let centroid = centroid
//			if (Ixx*Iyy-Ixy*Ixy).isApproxEqual(to: 0) {
//				return centroid
//			} else {
//			   var xS = (Iyy*Iwy-Ixy*Iwx)/(Ixx*Iyy-Ixy*Ixy) + centroid.x
//			   var yS = -(Ixx*Iwx-Ixy*Iwy)/(Ixx*Iyy-Ixy*Ixy) + centroid.y
//			   if xS.isApproxEqual(to: 0) { xS = 0 }
//			   if yS.isApproxEqual(to: 0) { yS = 0 }
//			   return SIMD2(xS, yS)
//			}
//		}()
		self.w = w
		for n in nodes {
			wProcessed[n] = false
		}
		wProcessed[nodesWith1ConnectedElement.first!] = true
		for _ in elements {
			guard let elementToProcess = elements.first(where: {
				(wProcessed[$0.node1] == true || wProcessed[$0.node2] == true) && wProcessed[$0.node1] != wProcessed[$0.node2]
			}) else { fatalError() }
			
			let sn = elementToProcess.node1
			let fn = elementToProcess.node2
			let t = elementToProcess.t
			let L = elementToProcess.length
			
			// Calculate `ρo` based on the element geometry
			let ro = ((sn.x - shearCenter.x) * (fn.y - shearCenter.y) -
					  (fn.x - shearCenter.x) * (sn.y - shearCenter.y)) / L
			
			// Update the `wo` dictionary
			if wProcessed[sn] == false  {
				wo[sn] = (wo[fn] ?? 0) - ro*L
				wProcessed[sn] = true
			} else if wProcessed[fn] == false  {
				wo[fn] = (wo[sn] ?? 0) + ro*L
				wProcessed[fn] = true
			}
			
			wno += 1/(2*A)*((wo[sn] ?? 0) + (wo[fn] ?? 0))*t*L
		}
		self.wo = wo
		self.wno = wno
	}
	struct Node: Codable, Hashable, Comparable, Identifiable, CustomStringConvertible {
		init(_ x: CGFloat, _ y: CGFloat) {
			self.x = x
			self.y = y
		}
		init(x: Double, y: Double) {
			self.x = x
			self.y = y
		}
		init(_ simd: SIMD2<Double>) {
			self.x = simd.x
			self.y = simd.y
		}
		var x: Double
		var y: Double
		var vector: SIMD2<Double> {
			SIMD2(x: x, y: y)
		}
		var id: String {
			"(\(x),\(y))"
		}
		var description: String {
			"(\(x.formatted(numFractionDigits: 4)),\(y.formatted(numFractionDigits: 4)))"
		}
		static func < (lhs: Node, rhs: Node) -> Bool {
			if lhs.x != rhs.x {
				return lhs.x < rhs.x
			}
			return lhs.y < rhs.y
		}
//		static func == (lhs: Node, rhs: Node) -> Bool {
//			lhs.x.isApproxEqual(to: rhs.x) && lhs.y.isApproxEqual(to: rhs.y)
//		}
		func isApproxEqual(to n: Node) -> Bool {
			x.isApproxEqual(to: n.x) && y.isApproxEqual(to: n.y)
		}
	}
	protocol LineElement: Codable, Identifiable, Hashable, CustomStringConvertible {
		var t: Double { get set }
		var node1: Node { get }
		var node2: Node { get }
		var centroid: SIMD2<Double> { get }
		var A: Double { get }
		var length: Double { get }
		var Ixx: Double { get }
		var Iyy: Double { get }
		var Ixy: Double { get }
		var J: Double { get }
		func updateNode1(to newNode: Node) -> Self
		func updateNode2(to newNode: Node) -> Self
	}
	struct StraightLineElement: LineElement {
		var id: String { "Straight: "+node1.vector.description + node2.vector.description }
		var description: String { "Straight Line: (\(node1.x.formatted(maxFractionDigits: 3)),\(node1.y.formatted(maxFractionDigits: 3))) -> (\(node2.x.formatted(maxFractionDigits: 3)),\(node2.y.formatted(maxFractionDigits: 3))), t: \(t)" }
		init(t: Double, node1: Node, node2: Node) {
			self.t = t
			self.node1 = node1
			self.node2 = node2
		}
		func updateNode1(to newNode: SSectionCFS.Node) -> SSectionCFS.StraightLineElement {
			return StraightLineElement(t: t, node1: newNode, node2: node2)
		}
		func updateNode2(to newNode: SSectionCFS.Node) -> SSectionCFS.StraightLineElement {
			return StraightLineElement(t: t, node1: node1, node2: newNode)
		}
		
		var t: Double
		var node1: Node
		var node2: Node
		var vectorPath: SIMD2<Double> {
			SIMD2(x: node2.x-node1.x, y: node2.y-node1.y)
		}
		var centroid: SIMD2<Double> {
			let x = (node1.x + node2.x) / 2
			let y = (node1.y + node2.y) / 2
			return SIMD2(x: x, y: y)
		}
		var length: Double { simd_distance(node1.vector, node2.vector) }
		var height: Double { abs(node1.y-node2.y) }
		var width: Double { abs(node1.x-node2.x) }
		var Ixx: Double { t*length*pow(height,2)/12 }
		var Iyy: Double { t*length*pow(width,2)/12 }
		var Ixy: Double { t*length*width*height/12 }
	}
	struct CircleArcLineElement: LineElement {
		var id: String { "Circle Arc: "+node1.vector.description + node2.vector.description + theta1.description + theta2.description + radius.description }
		var description: String { "Circle Arc: (\(node1.x.formatted(maxFractionDigits: 3)),\(node1.y.formatted(maxFractionDigits: 3))) -> (\(node2.x.formatted(maxFractionDigits: 3)),\(node2.y.formatted(maxFractionDigits: 3))), radius: \(radius), t: \(t)" }
//		init(t: Double, theta1: Double, theta2: Double, node1: Node, node2: Node) {
//			self.t = t
//			self.theta1 = theta1
//			self.theta2 = theta2
//			self.node1 = node1
//			self.node2 = node2
//			let center = {
//				let a = simd_double2x2(rows: [
//					simd_double2(tan(Double.pi/2-theta1), -1),
//					simd_double2(tan(Double.pi/2-theta2), -1)
//					])
//				let b = simd_double2(tan(Double.pi/2-theta1)*node1.x-node1.y, tan(Double.pi/2-theta2)*node2.x-node2.y)
//				let x = simd_mul(a.inverse, b)
//				return SIMD2(x.x, x.y)
//			}()
//			self.radius = hypot(center.x-node1.x, center.y-node1.y)
//		}
		init(t: Double, radius: Double, node1: Node, node2: Node, intersection: Node? = nil) {
			self.t = t
			if simd_distance(node1.vector, node2.vector) >= 2*radius {
				self.radius = sqrt(0.5*hypot(node2.x-node1.x,node2.y-node1.y))
			} else {
				self.radius = radius
			}
			self.node1 = node1
			self.node2 = node2
			let center = {
				let p1 = node1.vector, p2 = node2.vector
				let d = simd_distance(p1, p2)
				let midpoint = (p1 + p2) / 2
				let h = sqrt(pow(radius, 2) - pow(d / 2, 2))
				let perp = simd_normalize(SIMD2(p1.y - p2.y, p2.x - p1.x))
				let center1 = midpoint + h * perp
				let center2 = midpoint - h * perp
				
				if let intersection {
					let d1 = simd_distance(intersection.vector, center1)
					let d2 = simd_distance(intersection.vector, center2)
					if d1 > d2 {
						return SIMD2(x: center2.x, y: center2.y)
					} else {
						return SIMD2(x: center1.x, y: center1.y)
					}
				} else {
					if radius > 0 {
						return SIMD2(x: center1.x, y: center1.y)
					} else {
						return SIMD2(x: center2.x, y: center2.y)
					}
				}
			}()
			self.theta1 = atan((node1.x-center.x)/(node1.y-center.y))
			self.theta2 = atan((node2.x-center.x)/(node2.y-center.y))
		}
		init(t: Double, radius: Double, intersectionNode: Node, element1: StraightLineElement, element2: StraightLineElement) {
			let theta: Double = Double.pi-acos(simd_dot(element1.vectorPath, element2.vectorPath)/(element1.vectorPath.magnitude*element2.vectorPath.magnitude))
			let d: Double = tan(theta/2)*radius
			let n1, n2: Node
			if element1.node1.isApproxEqual(to: intersectionNode) {
				n1 = Node(d*simd_normalize(element1.vectorPath).x+intersectionNode.x,
						  d*simd_normalize(element1.vectorPath).y+intersectionNode.y)
			} else {
				n1 = Node(-d*simd_normalize(element1.vectorPath).x+intersectionNode.x,
						   -d*simd_normalize(element1.vectorPath).y+intersectionNode.y)
			}
			if element2.node1.isApproxEqual(to: intersectionNode) {
				n2 = Node(d*simd_normalize(element2.vectorPath).x+intersectionNode.x,
						  d*simd_normalize(element2.vectorPath).y+intersectionNode.y)
			} else {
				n2 = Node(-d*simd_normalize(element2.vectorPath).x+intersectionNode.x,
						   -d*simd_normalize(element2.vectorPath).y+intersectionNode.y)
			}
			self.init(t: t, radius: radius, node1: n1, node2: n2, intersection: intersectionNode)
		}
		func updateNode1(to newNode: SSectionCFS.Node) -> SSectionCFS.CircleArcLineElement {
			let element1 = CircleArcLineElement(t: t, radius: radius, node1: newNode, node2: node2)
			let element2 = CircleArcLineElement(t: t, radius: -radius, node1: newNode, node2: node2)
			if simd_distance(element1.center, center) < simd_distance(element2.center, center) {
				return element1
			} else {
				return element2
			}
		}
		func updateNode2(to newNode: SSectionCFS.Node) -> SSectionCFS.CircleArcLineElement {
			let element1 = CircleArcLineElement(t: t, radius: radius, node1: node1, node2: newNode)
			let element2 = CircleArcLineElement(t: t, radius: -radius, node1: node1, node2: newNode)
			if simd_distance(element1.center, center) < simd_distance(element2.center, center) {
				return element1
			} else {
				return element2
			}
		}
		
		var t: Double
		let radius: Double
		var node1: Node
		var node2: Node
		/// `alpha` is half of the total angle sweeping the arc length, in radians
		var alpha: Double { (theta2-theta1)/2 }
		/// Clockwise Angle from Y-Axis to node1, in radians
		let theta1: Double
		/// Clockwise Angle from Y-Axis to node2, in radians
		let theta2: Double
		var center: SIMD2<Double> {
			let p1 = node1.vector, p2 = node2.vector
			let d = simd_distance(p1, p2)
			let midpoint = (p1 + p2) / 2
			let h = sqrt(pow(radius, 2) - pow(d / 2, 2))
			let perp = simd_normalize(SIMD2(p1.y - p2.y, p2.x - p1.x))
			let center1 = midpoint + h * perp
			let center2 = midpoint - h * perp
			
			let d1 = simd_distance(apparentIntersection, center1)
			let d2 = simd_distance(apparentIntersection, center2)
			if d1 < d2 {
				return SIMD2(x: center2.x, y: center2.y)
			} else {
				return SIMD2(x: center1.x, y: center1.y)
			}
		}
		var apparentIntersection: SIMD2<Double> {
			let a = simd_double2x2(rows: [
				simd_double2(tan(Double.pi/2-theta1), -1),
				simd_double2(tan(Double.pi/2-theta2), -1)
				])
			let b = simd_double2(tan(Double.pi/2-theta1)*node1.x-node1.y, tan(Double.pi/2-theta2)*node2.x-node2.y)
			let v = simd_mul(a.inverse, b)
			if	v.x.isNaN { print("Invalid intersection.") }
			if	v.y.isNaN { print("Invalid intersection.") }
			return SIMD2(v.x, v.y)
			
			// Alternate method? - May not be correct
//			// Equation of the tangent lines
//			var line1: (A: Double, B: Double, C: Double) = (0, 0, 0)
//			var line2: (A: Double, B: Double, C: Double) = (0, 0, 0)
//			
//			// Line 1
//			if node1.x.isApproxEqual(to: center.x) {
//				line1 = (A: 1, B: 0, C: -node1.x)
//			} else if node1.y.isApproxEqual(to: center.y) {
//				line1 = (A: 0, B: 1, C: -node1.y)
//			} else {
//				let slope1 = -1 / ((node1.y - center.y) / (node1.x - center.x))
//				let intercept1 = node1.y - slope1 * node1.x
//				line1 = (A: slope1, B: -1, C: intercept1)
//			}
//			
//			// Line 2
//			if node2.x.isApproxEqual(to: center.x) {
//				line2 = (A: 1, B: 0, C: -node2.x)
//			} else if node2.y.isApproxEqual(to: center.y) {
//				line2 = (A: 0, B: 1, C: -node2.y)
//			} else {
//				let slope2 = -1 / ((node2.y - center.y) / (node2.x - center.x))
//				let intercept2 = node2.y - slope2 * node2.x
//				line2 = (A: slope2, B: -1, C: intercept2)
//			}
//			
//			// Solve the system of equations Ax + By + C = 0 for the two lines
//			let determinant = line1.A * line2.B - line2.A * line1.B
//			
//			// If determinant is 0, the lines are parallel or coincident
//			if determinant == 0 {
//				print("Apparent Intersection not found for \(self)")
//				return SIMD2<Double>(x: Double.nan, y: Double.nan)
//			}
//			
//			// Calculate intersection
//			let x = (line2.B * -line1.C - line1.B * -line2.C) / determinant
//			let y = (line1.A * -line2.C - line2.A * -line1.C) / determinant
//			return SIMD2<Double>(x: x, y: y)
		}
		/// Distance from center to centroid
		var rAvg: Double {
			radius*sin(alpha)/(alpha)
		}
		var centroid: SIMD2<Double> {
			// Compute the angle between the points using dot product
			let dotProduct = dot(normalize(node1.vector - center), normalize(node2.vector - center))
			// Clamp the dot product to avoid floating point errors that might cause NaN
			let clampedDotProduct = min(max(dotProduct, -1.0), 1.0)
			// Calculate the central angle θ
			let angle = acos(clampedDotProduct)
			// Compute the centroid distance from the center along the angle bisector
			let centroidDistance = (2 * radius * sin(angle / 2)) / angle
			// Find the direction of the centroid (normalized vector of the bisector)
			let bisector = normalize((node1.vector - center) + (node2.vector - center))
			// Calculate the centroid's position
			let centroid = center + bisector * centroidDistance
			return centroid
			//return SIMD2(x: radius*(cos(theta1)-cos(theta2))/(theta2-theta1), y: radius*(sin(theta2)-sin(theta1))/(theta2-theta1))
		}
		var length: Double { 2*abs(alpha*radius) }
		var Ixx: Double {
			(((theta2-theta1)+sin(theta2)*cos(theta2)-sin(theta1)*cos(theta1))/2 - pow(sin(theta2)-sin(theta1),2)/(theta2-theta1))*pow(radius,3)*t
		}
		var Iyy: Double {
			(((theta2-theta1)-sin(theta2)*cos(theta2)+sin(theta1)*cos(theta1))/2 - pow(cos(theta1)-cos(theta2),2)/(theta2-theta1))*pow(radius,3)*t
		}
		var Ixy: Double {
			((pow(sin(theta2),2)-pow(sin(theta1),2))/2 +
			(sin(theta2)-sin(theta1))*(cos(theta2)-cos(theta1))/(theta2-theta1))*pow(radius,3)
		}
	}
	
	// MARK: Helper functions for UI
	mutating func setAllThicknesses(to t: Double) {
		for i in straightElements.indices {
			var new = straightElements[i]
			new.t = t
			straightElements[i] = new
		}
		for i in circleArcElements.indices {
			var new = circleArcElements[i]
			new.t = t
			circleArcElements[i] = new
		}
		updateSectionProperties()
	}
	mutating func updateWebDepth(useRoundedCorners: Bool, webDepth: Double, lipLength: Double, radius: Double) {
		if useRoundedCorners { removeRoundedCorners() }
		straightElements[0].node2.y = webDepth
		straightElements[2].node1.y = webDepth
		straightElements[4].node1.y = webDepth
		straightElements[2].node2.y = webDepth
		straightElements[4].node2.y = webDepth-lipLength
		if useRoundedCorners { addRoundedCorners(ofRadius: radius) }
		updateSectionProperties()
	}
	mutating func updateFlangeWidth(useRoundedCorners: Bool, flangeWidth: Double, webDepth: Double, lipLength: Double, radius: Double) {
		if useRoundedCorners { removeRoundedCorners() }
		straightElements[1].node2.x = flangeWidth
		straightElements[2].node2.x = flangeWidth
		straightElements[3].node1.x = flangeWidth
		straightElements[4].node1.x = flangeWidth
		straightElements[3].node2.x = flangeWidth
		straightElements[4].node2.x = flangeWidth
		straightElements[3].node2.y = lipLength
		straightElements[4].node2.y = webDepth-lipLength
		if useRoundedCorners { addRoundedCorners(ofRadius: radius) }
		updateSectionProperties()
	}
	mutating func convertToCenterline(isZ: Bool, webDepth: Double, thickness: Double, radius: Double) {
		var restoreRoundedCorners = false
		if !circleArcElements.isEmpty {
			restoreRoundedCorners = true
			self.removeRoundedCorners()
		}
		let m = isZ ? 0.5:1
		for i in straightElements.indices {
			if straightElements[i].node1.x > 1.5*thickness {
				straightElements[i].node1.x += +thickness*m
			}
			if straightElements[i].node1.x < -1.5*thickness {
				straightElements[i].node1.x += -thickness*m
			}
			if straightElements[i].node1.y > webDepth/2 && straightElements[i].node1.y < (webDepth-thickness) {
				//  node is at end of lip
				straightElements[i].node1.y += +thickness/2
			} else if straightElements[i].node1.y < webDepth/2 && straightElements[i].node1.y > (thickness) {
				//  node is at end of lip
				straightElements[i].node1.y += +thickness/2
			} else {
				if straightElements[i].node1.y > webDepth/2 {
					straightElements[i].node1.y += +thickness
				}
			}
			if straightElements[i].node2.x > 1.5*thickness {
				straightElements[i].node2.x += +thickness*m
			}
			if straightElements[i].node2.x < -1.5*thickness {
				straightElements[i].node2.x += -thickness*m
			}
			if straightElements[i].node2.y > webDepth/2 && straightElements[i].node2.y < (webDepth-thickness) {
				//  node is at end of lip
				straightElements[i].node2.y += +thickness/2
			} else if straightElements[i].node2.y < webDepth/2 && straightElements[i].node2.y > (thickness) {
				//  node is at end of lip
				straightElements[i].node2.y += +thickness/2
			} else {
				if straightElements[i].node2.y > webDepth/2 {
					straightElements[i].node2.y += +thickness
				}
			}
		}
		if restoreRoundedCorners {
			self.addRoundedCorners(ofRadius: radius)
		}
		updateSectionProperties()
	}
	mutating func convertToOutToOut(isZ: Bool, webDepth: Double, thickness: Double, radius: Double) {
		var restoreRoundedCorners = false
		if !circleArcElements.isEmpty {
			restoreRoundedCorners = true
			self.removeRoundedCorners()
		}
		let m = isZ ? 0.5:1
		for i in straightElements.indices {
			if straightElements[i].node1.x > 1.5*thickness {
				straightElements[i].node1.x += -thickness*m
			}
			if straightElements[i].node1.x < -1.5*thickness {
				straightElements[i].node1.x += +thickness*m
			}
			if straightElements[i].node1.y > webDepth/2 && straightElements[i].node1.y < (webDepth-thickness) {
				//  node is at end of lip
				straightElements[i].node1.y += -thickness/2
			} else if straightElements[i].node1.y < webDepth/2 && straightElements[i].node1.y > (thickness) {
				//  node is at end of lip
				straightElements[i].node1.y += -thickness/2
			} else {
				if straightElements[i].node1.y > webDepth/2 {
					straightElements[i].node1.y += -thickness
				}
			}
			if straightElements[i].node2.x > 1.5*thickness {
				straightElements[i].node2.x += -thickness*m
			}
			if straightElements[i].node2.x < -1.5*thickness {
				straightElements[i].node2.x += +thickness*m
			}
			if straightElements[i].node2.y > webDepth/2 && straightElements[i].node2.y < (webDepth-thickness) {
				//  node is at end of lip
				straightElements[i].node2.y += -thickness/2
			} else if straightElements[i].node2.y < webDepth/2 && straightElements[i].node2.y > (thickness) {
				//  node is at end of lip
				straightElements[i].node2.y += -thickness/2
			} else {
				if straightElements[i].node2.y > webDepth/2 {
					straightElements[i].node2.y += -thickness
				}
			}
		}
		if restoreRoundedCorners {
			self.addRoundedCorners(ofRadius: radius)
		}
		updateSectionProperties()
	}
	mutating func switchCZtemplates(webDepth: Double) {
		for i in straightElements.indices {
			if straightElements[i].node1.y < webDepth/2 {
				straightElements[i].node1.x.negate()
			}
			if straightElements[i].node2.y < webDepth/2 {
				straightElements[i].node2.x.negate()
			}
		}
		for i in circleArcElements.indices {
			if circleArcElements[i].node1.y < webDepth/2 {
				circleArcElements[i].node1.x.negate()
			}
			if circleArcElements[i].node2.y < webDepth/2 {
				circleArcElements[i].node2.x.negate()
			}
		}
		updateSectionProperties()
	}
	mutating func addRoundedCorners(ofRadius r: Double) {
		// find corner nodes
		var cornerNodesExist: Bool = true
		while cornerNodesExist {
			let nodeCounts: [Node:Int] = {
				var nodeCounts: [Node: Int] = [:]
				for i in straightElements {
					if nodeCounts.contains(where: { i.node1.isApproxEqual(to: $0.key) }) {
						if nodeCounts[i.node1] != nil {
							nodeCounts[i.node1]! += 1
						} else {
							if let node = nodeCounts.first(where: {i.node1.isApproxEqual(to: $0.key)}) {
								nodeCounts[node.key]? += 1
							}
						}
					} else {
						nodeCounts[i.node1] = 1
					}
					if nodeCounts.contains(where: { i.node2.isApproxEqual(to: $0.key) }) {
						if nodeCounts[i.node2] != nil {
							nodeCounts[i.node2]! += 1
						} else {
							if let node = nodeCounts.first(where: {i.node2.isApproxEqual(to: $0.key)}) {
								nodeCounts[node.key]? += 1
							}
						}
					} else {
						nodeCounts[i.node2] = 1
					}
				}
				return nodeCounts
			}()
			let nodesWith2ConnectedElements = nodeCounts.filter({ $0.value == 2 })
			if nodesWith2ConnectedElements.isEmpty {
				cornerNodesExist = false
				break
			}
			for node in nodesWith2ConnectedElements.keys {
				var elements: [Int] = []
				for i in straightElements.indices {
					if straightElements[i].node1.isApproxEqual(to: node) || straightElements[i].node2.isApproxEqual(to: node) {
						elements.append(i)
					}
					if elements.count == 2 {
						break
					}
				}
				let theta: Double = Double.pi-acos(simd_dot(straightElements[elements[0]].vectorPath, straightElements[elements[1]].vectorPath)/(straightElements[elements[0]].vectorPath.magnitude*straightElements[elements[1]].vectorPath.magnitude))
				if abs(theta) > 0.1 {
					let newArc = CircleArcLineElement(t: straightElements[elements[0]].t, radius: r, intersectionNode: node, element1: straightElements[elements[0]], element2: straightElements[elements[1]])
					if straightElements[elements[0]].node1.isApproxEqual(to: node) {
						straightElements[elements[0]].node1 = newArc.node1
					}
					if straightElements[elements[0]].node2.isApproxEqual(to: node) {
						straightElements[elements[0]].node2 = newArc.node1
					}
					if straightElements[elements[1]].node1.isApproxEqual(to: node) {
						straightElements[elements[1]].node1 = newArc.node2
					}
					if straightElements[elements[1]].node2.isApproxEqual(to: node) {
						straightElements[elements[1]].node2 = newArc.node2
					}
					circleArcElements.append(newArc)
					break
				}
			}
		}
		updateSectionProperties()
	}
	mutating func removeRoundedCorners() {
		while !circleArcElements.isEmpty {
			let arc = circleArcElements.first!
			
			circleArcElements.removeAll(where: { $0 == arc })
			
			for i in straightElements.indices {
				if straightElements[i].node1.isApproxEqual(to: arc.node1) || straightElements[i].node1.isApproxEqual(to: arc.node2) {
					straightElements[i].node1 = Node(arc.apparentIntersection)
				}
				if straightElements[i].node2.isApproxEqual(to: arc.node1) || straightElements[i].node2.isApproxEqual(to: arc.node2) {
					straightElements[i].node2 = Node(arc.apparentIntersection)
				}
			}
		}
		updateSectionProperties()
	}
	
	static var defaultSection: SSectionCFS {
		SSectionCFS(straightSubsections: [
			SSectionCFS.StraightLineElement(t: 0.0188, node1: .init(0,0), node2: .init(0,1.625)), // Web
			SSectionCFS.StraightLineElement(t: 0.0188, node1: .init(0,0), node2: .init(1.25,0)), // Top Flange
			SSectionCFS.StraightLineElement(t: 0.0188, node1: .init(0,1.625), node2: .init(1.25,1.625)), // Bottom Flange
			SSectionCFS.StraightLineElement(t: 0.0188, node1: .init(1.25,0), node2: .init(1.25,3/16)), // Top Lip
			SSectionCFS.StraightLineElement(t: 0.0188, node1: .init(1.25,1.625), node2: .init(1.25,1.625-3/16)), // Bottom Lip
		])
	}
}
extension SSectionCFS.LineElement {
	var A: Double { t*length }
	var J: Double { length*pow(t,3)/3 }
}

/// Wrapper struct to enable multiple section types to be saved.
@dynamicMemberLookup
struct AnySSection: Codable, Identifiable, Hashable, CodableWrapper {
	var id: UUID
	var sectionType: SSectionType
	var wrappedValue: SSection
	init(_ wrappedValue: SSection) {
		id = UUID()
		self.sectionType = wrappedValue.sectionType
		self.wrappedValue = wrappedValue
	}
	enum SSectionType: String, Codable {
		case CFS
		var structType: any SSection.Type {
			switch self {
			case .CFS: return SSectionCFS.self
			}
		}
	}
	subscript<T>(dynamicMember keyPath: KeyPath<SSection, T>) -> T {
		wrappedValue[keyPath: keyPath]
	}
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.sectionType == rhs.sectionType &&
		lhs.id == rhs.id
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(sectionType)
		hasher.combine(id)
	}
	func decode() -> SSection { wrappedValue }
	enum CodingKeys: CodingKey {
		case id, sectionType, wrappedValue
	}
	init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		id = try c.decode(UUID.self, forKey: .id)
		sectionType = try c.decode(SSectionType.self, forKey: .sectionType)
		wrappedValue = try c.decode(sectionType.structType, forKey: .wrappedValue)
	}
	func encode(to encoder: Encoder) throws {
		var c = encoder.container(keyedBy: CodingKeys.self)
		try c.encode(id, forKey: .id)
		try c.encode(sectionType, forKey: .sectionType)
		try c.encode(wrappedValue, forKey: .wrappedValue)
	}
}
