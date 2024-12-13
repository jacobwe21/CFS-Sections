//
//  SSectionView.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 12/1/24.
//

import SwiftUI
import Spatial

struct SSectionView: View {
	@Environment(\.colorTheme) var colorTheme
	
	@Binding var section: SSectionCFS
	let isEditable: Bool
	@Binding var selectedNode: SSectionCFS.Node?
	@Binding var selectedElement: (any SSectionCFS.LineElement)?
	var showWarpingPlot: Bool
	
	init(section: Binding<SSectionCFS>, isEditable: Bool, selectedNode: Binding<SSectionCFS.Node?>, selectedElement: Binding<(any SSectionCFS.LineElement)?>, showWarping: Bool) {
		_section = section
		self.isEditable = isEditable
		_selectedNode = selectedNode
		_selectedElement = selectedElement
		showWarpingPlot = showWarping
		self.sectionShearCenter = self.section.shearCenter
	}
	init(section: Binding<SSectionCFS>) {
		_section = section
		self.isEditable = false
		_selectedNode = .constant(nil)
		_selectedElement = .constant(nil)
		showWarpingPlot = false
		self.sectionShearCenter = self.section.shearCenter
	}
	
	var nodeSize: CGFloat { isEditable ? 20:8 }
	
	func scaleFactor(geo: GeometryProxy) -> CGFloat {
		let shearCenter = sectionShearCenter
		let xMax = max(section.xMax, shearCenter.x)
		let yMax = max(section.yMax, shearCenter.y)
		let xMin = min(section.xMin, shearCenter.x)
		let yMin = min(section.yMin, shearCenter.y)
		let scale1 = geo.size.width*0.8/(xMax-xMin)
		let scale2 = geo.size.height*0.8/(yMax-yMin)
		return min(scale1, scale2)
	}
	private var sectionCenter: CGPoint {
		let shearCenter = sectionShearCenter
		let xMax = max(section.xMax, shearCenter.x)
		let yMax = max(section.yMax, shearCenter.y)
		let xMin = min(section.xMin, shearCenter.x)
		let yMin = min(section.yMin, shearCenter.y)
		return CGPoint(x: (xMax+xMin)/2, y: (yMax+yMin)/2)
	}
	@State private var sectionShearCenter: SIMD2<Double> =  SIMD2<Double>(x:0,y:0)
	
	var angleX: Angle {
		return Angle(-section.theta)
	}
	var angleY: Angle {
		return Angle(-section.theta + Angle2D(degrees: 90))
	}
	
	var body: some View {
		GeometryReader { geo in
			// X-Y Axis Arrows
			ZStack {
				PositionedArrowView(PositionedArrow(from: CGVector(distance: 30, theta: .degrees(90)), anchorVector: CGVector(dx: 15-geo.size.width/2, dy: 15-geo.size.height/2), anchoredAtHead: false, arrowWidth: 3, arrowheadLength: 8), color: Color.primary, fillColor: Color.clear, strokeStyle: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round), label: Text("Y"))
				PositionedArrowView(PositionedArrow(from: CGVector(distance: 30, theta: .degrees(0)), anchorVector: CGVector(dx: 15-geo.size.width/2, dy: 15-geo.size.height/2), anchoredAtHead: false, arrowWidth: 3, arrowheadLength: 8), color: Color.primary, fillColor: Color.clear, strokeStyle: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round), label: Text("X"))
			}
			
			// X-Y Rotated Axis
			ZStack {
				SlantedLine(angle: angleX, lineWidth: 1, lineCap: .square, dash: [10, 8])
				SlantedLine(angle: angleY, lineWidth: 1, lineCap: .square, dash: [10, 8])
			}
			
			// Straight Elements
			ForEach(section.straightElements, id: \.id) { subsection in
				LineFromPoints(points: [subsection.node1.vector*scaleFactor(geo: geo), subsection.node2.vector*scaleFactor(geo: geo)])
					.stroke(MyColors.blue, style: StrokeStyle(lineWidth: subsection.t*scaleFactor(geo: geo), lineCap: .round, lineJoin: .round, dash: []))
//					.onTapGesture {
//						if selectedElement == subsection { selectedElement = nil }
//						else { selectedElement = subsection }
//					}
			}
			.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
			
			// Circular Arc Elements
			ForEach(section.circleArcElements, id: \.id) { subsection in
				Path { path in
					path.move(to: CGPoint(x: subsection.node1.x*scaleFactor(geo: geo), y: subsection.node1.y*scaleFactor(geo: geo)))
					path.addArc(tangent1End: CGPoint(x: subsection.apparentIntersection.x*scaleFactor(geo: geo), y: subsection.apparentIntersection.y*scaleFactor(geo: geo)), tangent2End: CGPoint(x: subsection.node2.x*scaleFactor(geo: geo), y: subsection.node2.y*scaleFactor(geo: geo)), radius: subsection.radius*scaleFactor(geo: geo))
				}
				.stroke(MyColors.blue, style: StrokeStyle(lineWidth: subsection.t*scaleFactor(geo: geo), lineCap: .round, lineJoin: .round, dash: []))
//				.onTapGesture {
//					if selectedElement == subsection { selectedElement = nil }
//					else { selectedElement = subsection }
//				}
			}
			.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
			
//			// Circular Arc Elements - Trace circle
//			ForEach(section.circleArcElements, id: \.id) { subsection in
//				Path { path in
//					path.move(to: CGPoint(x: subsection.node1.x*scaleFactor(geo: geo), y: subsection.node1.y*scaleFactor(geo: geo)))
//					path.addArc(center: CGPoint(x: subsection.center.x*scaleFactor(geo: geo), y: subsection.center.y*scaleFactor(geo: geo)), radius: subsection.radius*scaleFactor(geo: geo), startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
//				}
//				.stroke(MyColors.lightMint, style: StrokeStyle(lineWidth: subsection.t*scaleFactor(geo: geo)*0.2, lineCap: .round, lineJoin: .round, dash: [10.0,5.0]))
//			}
//			.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
			
			// Nodes
			ForEach(Array(section.nodes), id: \.id) { node in
				Circle()
					.fill(colorTheme.accentColor)
					.frame(width: nodeSize, height: nodeSize)
					.offset(x: -nodeSize/2, y: -nodeSize/2)
					.offset(x: node.x*scaleFactor(geo: geo), y: node.y*scaleFactor(geo: geo))
					.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
//					.onTapGesture {
//						if isEditable {
//							if selectedNode == node { selectedNode = nil }
//							else {
//								selectedNode = nil
//								selectedNode = node
//							}
//						}
//					}
			}
			if showWarpingPlot {
				ForEach(Array(section.nodes), id: \.id) { node in
					let w = section.warpingNormal(for: node)
					let percentOfMax: Double
					if w.isNaN {
						print("w is NaN")
						percentOfMax = 0
					} else {
						percentOfMax = w/section.warpingMax
					}
					return Text("w=\(w)")
						.foregroundStyle(MyColors.gold)
						.offset(x: -3, y: -3)
						.offset(x: node.x*scaleFactor(geo: geo), y: node.y*scaleFactor(geo: geo))
						.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
				}
//				ForEach(Array(section.nodes), id: \.id) { node in
//					let w = section.warpingNormal(for: node)
//					let percentOfMax: Double
//					let transform: CATransform3D
//					if w.isNaN {
//						print("w is NaN")
//						percentOfMax = 0
//					} else {
//						percentOfMax = w/section.warpingMax
//					}
//					if w.isNaN || percentOfMax == 0 || percentOfMax.isNaN || percentOfMax.isInfinite {
//						print("Percent of max w: \(percentOfMax)")
//						transform = CATransform3D()
//					} else {
//						transform = CATransform3DMakeScale(1000*percentOfMax, 1000*percentOfMax, 1000*percentOfMax)
//					}
//					return Circle()
//						.fill(MyColors.gold)
//						.hueRotation(.degrees(0.33*percentOfMax))
//						.frame(width: 6, height: 6)
//						.offset(x: -3, y: -3)
//						.offset(x: node.x*scaleFactor(geo: geo), y: node.y*scaleFactor(geo: geo))
//						.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
//						//.rotation3DEffect(.degrees(0.33*percentOfMax), axis: (0,0,1), anchor: .center, anchorZ: percentOfMax, perspective: 1.0)
//						.projectionEffect(.init(transform))
//					// Transform node location
//				}
			}
//			Group {
//				ForEach(section.circleArcElements.map(\.center), id: \.description) { node in
//					Circle()
//						.fill(.green)
//						.frame(width: nodeSize/2, height: nodeSize/2)
//						.offset(x: -nodeSize/4, y: -nodeSize/4)
//						.offset(x: node.x*scaleFactor(geo: geo), y: node.y*scaleFactor(geo: geo))
//						.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
//				}
//				ForEach(section.circleArcElements.map(\.apparentIntersection), id: \.description) { node in
//					Circle()
//						.fill(MyColors.coral)
//						.frame(width: nodeSize/2, height: nodeSize/2)
//						.offset(x: -nodeSize/4, y: -nodeSize/4)
//						.offset(x: node.x*scaleFactor(geo: geo), y: node.y*scaleFactor(geo: geo))
//						.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
//				}
//				ForEach(section.circleArcElements.map(\.centroid), id: \.description) { node in
//					Circle()
//						.fill(MyColors.magenta)
//						.frame(width: nodeSize/2, height: nodeSize/2)
//						.offset(x: -nodeSize/4, y: -nodeSize/4)
//						.offset(x: node.x*scaleFactor(geo: geo), y: node.y*scaleFactor(geo: geo))
//						.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
//				}
//			}
//			ForEach(section.straightElements.map(\.centroid), id: \.description) { node in
//				Circle()
//					.fill(MyColors.magenta)
//					.frame(width: nodeSize/2, height: nodeSize/2)
//					.offset(x: -nodeSize/4, y: -nodeSize/4)
//					.offset(x: node.x*scaleFactor(geo: geo), y: node.y*scaleFactor(geo: geo))
//					.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
//			}
			// Centroid
			Circle()
				.fill(colorTheme.highAccentColor)
				.frame(width: 14, height: 14)
				.offset(x: -7, y: -7)
				.offset(x: section.centroid.x*scaleFactor(geo: geo), y: section.centroid.y*scaleFactor(geo: geo))
				.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
			// Shear Center
			Circle()
				.strokeBorder(colorTheme.destructiveColor, lineWidth: 4)
				.frame(width: 14, height: 14)
				.offset(x: -7, y: -7)
				.offset(x: section.shearCenter.x*scaleFactor(geo: geo), y: section.shearCenter.y*scaleFactor(geo: geo))
				.offset(x: geo.size.width/2-sectionCenter.x*scaleFactor(geo: geo), y: geo.size.height/2-sectionCenter.y*scaleFactor(geo: geo))
		}
		.background(MyColors.systemBackground)
		.border(Color.primary, width: 0.5)
		.onChange(of: isEditable) {
			selectedElement = nil
			selectedNode = nil
		}
		.onChange(of: section) {
			section.updateSectionProperties()
			self.sectionShearCenter = section.shearCenter
		}
		.onAppear {
			self.sectionShearCenter = section.shearCenter
		}
	}
}

#Preview {
	SSectionView(section: .constant(SSectionCFS.defaultSection), isEditable: true, selectedNode: .constant(nil), selectedElement: .constant(nil), showWarping: false)
}
