//
//  SSectionEditor.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 11/30/24.
//

import SwiftUI

struct SSectionEditor: View {
	@Bindable var sectionData: SSectionData
	@Environment(\.modelContext) private var modelContext
	@State var showResults: Bool = true
	@State var section: SSectionCFS
	@State var showWarpingFunction: Bool = false
	
	@State private var selectedNode: SSectionCFS.Node? = nil
	@State private var selectedElement: (any SSectionCFS.LineElement)? = nil
	
	init(section: SSectionData) {
		self.sectionData = section
		_section = State(initialValue: section.section)
		self.section.updateSectionProperties()
	}
	
    var body: some View {
		ZStack {
			OrientedStack(spacing: 0) {
				SSectionView(section: $section, isEditable: !showResults, selectedNode: $selectedNode, selectedElement: $selectedElement, showWarping: showWarpingFunction)
				if showResults {
					SSectionResultsView(showWarpingFunction: $showWarpingFunction, section: section)
				} else {
					SSectionInputsView(section: $section, sectionName: $sectionData.name, selectedNode: $selectedNode, selectedElement: $selectedElement)
				}
			}
		}
		.navigationTitle("\(sectionData.name) - \(sectionData.timestamp.formatted(date: .numeric, time: .shortened))")
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(showResults ? "Edit Beam":"View Results", systemImage: showResults ? "pencil.and.ruler":"ruler") {
					showResults.toggle()
				}
			}
			ToolbarItem(placement: .automatic) {
				Button {
					print("Saved Section")
					section.updateSectionProperties()
					sectionData.section = section
					sectionData.timestamp = Date()
				} label: {
					Label("Save Structural Section", systemImage: "opticaldisc")
				}
			}
		}
		.onChange(of: sectionData) {
			print("Loaded New Section")
			section.updateSectionProperties()
			section = sectionData.section
		}
    }
	
	private func deleteItem() -> KeyPress.Result {
		withAnimation {
			modelContext.delete(sectionData)
			return KeyPress.Result.handled
		}
	}
}

struct SSectionInputsView: View {
	@Binding var section: SSectionCFS
	@Binding var sectionName: String
	@Binding var selectedNode: SSectionCFS.Node?
	@Binding var selectedElement: (any SSectionCFS.LineElement)?
	
	var body: some View {
		VStack {
			HStack {
				Text("Section Name:")
				Spacer()
				TextField("Section Name", text: $sectionName).textFieldStyle(.roundedBorder)
			}
			Text("Editing templates is currently not supported. Do not edit the dimensions below.")
				.font(.title2)
			List {
				ForEach($section.straightElements) { element in
					VStack(alignment: .leading) {
						Text(element.wrappedValue.description)
						Row(text: "Node 1: X", value: element.node1.x)
						Row(text: "Node 1: Y", value: element.node1.y)
						Row(text: "Node 2: X", value: element.node2.x)
						Row(text: "Node 2: Y", value: element.node2.y)
						Row(text: "Thickness", value: element.t)
					}
				}
				ForEach($section.circleArcElements) { element in
					VStack(alignment: .leading) {
						Text(element.wrappedValue.description)
						Row(text: "Node 1: X", value: element.node1.x)
						Row(text: "Node 1: Y", value: element.node1.y)
						Row(text: "Node 2: X", value: element.node2.x)
						Row(text: "Node 2: Y", value: element.node2.y)
						Row(text: "Thickness", value: element.t)
//						if let element = element as? Binding<SSectionCFS.CircleArcLineElement> {
//							Row(text: "Radius", value: element.radius)
//						}
					}
				}
			}
			// TO-DO - update section properties and link nodes together...
//			.onChange(of: section) { oldValue, newValue in
//				if !newValue.x.isNaN || !newValue.y.isNaN {
//					section.moveNode(oldValue, to: newValue)
//					section.updateSectionProperties()
//				}
//			}
//			.onChange(of: element.node2) { oldValue, newValue in
//				if !newValue.x.isNaN || !newValue.y.isNaN {
//					section.moveNode(oldValue, to: newValue)
//					section.updateSectionProperties()
//				}
//			}
//			.onChange(of: element.t) {
//				section.updateSectionProperties()
//			}
			
			if selectedNode == nil && selectedElement == nil {
//				Text("Select a Node or Element to edit.")
//					.font(.title2)
//					.padding()
			} else if selectedNode != nil {
				Text("Edit Node:").font(.headline)
				HStack {
					Text("X:")
					Spacer()
					MyNumericField("X", value: Binding($selectedNode)?.x ?? .constant(0))
				}
				HStack {
					Text("Y:")
					Spacer()
					MyNumericField("Y", value: Binding($selectedNode)?.y ?? .constant(0))
				}
			} else if selectedElement != nil {
				Text("Edit Element:").font(.headline)
				MyNumericField("Thickness:", value: Binding($selectedElement)?.t ?? .constant(0))
			}
			Spacer()
		}
		.padding()
//		.onChange(of: selectedNode ?? SSectionCFS.Node(x: Double.nan, y: Double.nan)) { oldValue, newValue in
//			if !newValue.x.isNaN || !newValue.y.isNaN {
//				section.moveNode(oldValue, to: newValue)
//			}
//		}
	}
	
	struct Row: View {
		let text: String
		@Binding var value: Double
		var body: some View {
			HStack {
				Text(text)
				Spacer()
				TextField(text, value: $value, format: .number)
					.frame(width: 120)
					.textFieldStyle(.roundedBorder)
			}
		}
	}
}


struct SSectionResultsView: View {
	@Binding var showWarpingFunction: Bool
	var section: SSectionCFS
	var body: some View {
		Form {
			LabeledContent("Area") {
				Text(section.A.formatted(sigFigs: 2...5))
			}
			LabeledContent("Height (based on centerline)") {
				Text((section.yMax-section.yMin).formatted(sigFigs: 2...5))
			}
			LabeledContent("Width (based on centerline)") {
				Text((section.xMax-section.xMin).formatted(sigFigs: 2...5))
			}
			Section {
				LabeledContent("Ixx (Geometric)") {
					Text(section.Ixx.formatted(sigFigs: 3...5))
				}
				LabeledContent("Iyy (Geometric)") {
					Text(section.Iyy.formatted(sigFigs: 3...5))
				}
				LabeledContent("Ixy (Geomtric)") {
					Text(section.Ixy.formatted(sigFigs: 3...5))
				}
				LabeledContent("IX (Principle)") {
					Text(section.IX.formatted(sigFigs: 3...5))
				}
				LabeledContent("IY (Principle)") {
					Text(section.IY.formatted(sigFigs: 3...5))
				}
				LabeledContent("Iz (Polar)") {
					Text(section.Iz.formatted(sigFigs: 3...5))
				}
				LabeledContent("θ (Angle in radians to Principal Axes)") {
					Text(section.theta.radians.formatted(sigFigs: 3...5))
				}
				LabeledContent("θ (Angle in degrees to Principal Axes)") {
					Text(section.theta.degrees.formatted(sigFigs: 3...5))
				}
				LabeledContent("Iwx (Geometric Warping)") {
					Text(section.Iwx.formatted(sigFigs: 3...5))
				}
				LabeledContent("Iwy (Geometric Warping)") {
					Text(section.Iwy.formatted(sigFigs: 3...5))
				}
			} header: {
				Text("Moments of Inertia")
			}
			Section {
				LabeledContent("Sxx (Geometric)") {
					Text(section.Sxx.formatted(sigFigs: 3...5))
				}
				LabeledContent("Syy (Geometric)") {
					Text(section.Syy.formatted(sigFigs: 3...5))
				}
			} header: {
				Text("Elastic Section Modulus")
			}
			Section {
				LabeledContent("rxx (Geometric)") {
					Text(section.rxx.formatted(sigFigs: 3...5))
				}
				LabeledContent("ryy (Geometric)") {
					Text(section.ryy.formatted(sigFigs: 3...5))
				}
//				LabeledContent("ro (Polar)") {
//					Text(section.ro.formatted(sigFigs: 3...5))
//				}
			} header: {
				Text("Radius of Gyration")
			}
			Section {
//				LabeledContent("w distribution:") {
//					Text(section.warpingInfo2)
//				}
				LabeledContent("w normal distribution:") {
					Text(section.warpingInfo)
				}
				LabeledContent("wno") {
					Text(section.wno.formatted(sigFigs: 3...5))
				}
				LabeledContent("Cw") {
					Text(section.Cw.formatted(sigFigs: 3...5))
				}
				LabeledContent("J") {
					Text(section.J.formatted(sigFigs: 3...5))
				}
				Button {
					showWarpingFunction.toggle()
				} label: {
					Text("\(showWarpingFunction ? "Hide":"Show") Warping Distribution Function (ω)").foregroundStyle(Color.accentColor)
				}
			} header: {
				Text("Torsional Properties")
			}
			Section {
				LabeledContent("X") {
					Text(section.centroid.x.formatted(maxFractionDigits: 5))
				}
				LabeledContent("Y") {
					Text(section.centroid.y.formatted(maxFractionDigits: 5))
				}
			} header: {
				Text("Centroid")
			} footer: {
				Text("Dimensions relative to input coordinates.").font(.footnote)
			}
			Section {
				LabeledContent("X") {
					Text(section.shearCenter.x.formatted(maxFractionDigits: 5))
				}
				LabeledContent("Y") {
					Text(section.shearCenter.y.formatted(maxFractionDigits: 5))
				}
				LabeledContent("X, from Centroid") {
					Text((section.shearCenter.x-section.centroid.x).formatted(maxFractionDigits: 5))
				}
				LabeledContent("Y, from Centroid") {
					Text((section.shearCenter.y-section.centroid.y).formatted(maxFractionDigits: 5))
				}
			} header: {
			 	Text("Shear Center")
			} footer: {
				Text("Dimensions relative to input coordinates except as noted.").font(.footnote)
			}
			Section {
				LabeledContent("# of Closed Cells") {
					Text(section.findClosedLoops(lineSegments: section.elements).count.formatted())
				}
//				LabeledContent("element data:") {
//					Text(section.elementInfo)
//				}
//				LabeledContent("ρ list:") {
//					Text(section.r.description)
//				}
//				LabeledContent("ρ arcs list:") {
//					Text(section.rCircles.description)
//				}
				LabeledContent("End Nodes") {
					ForEach(section.nodesWith1ConnectedElement) {
						Text($0.description)
					}
				}
				LabeledContent("Interior Nodes") {
					ForEach(section.nodesWith2ConnectedElements) {
						Text($0.description)
					}
				}
			} header: {
				Text("Other")
			}
		}
		.foregroundStyle(.primary)
		.formStyle(.grouped)
	}
}

#Preview {
	do {
		let previewer = try PreviewWithSwiftData(dataObjects: [SSectionData(timestamp: Date(), name: "Test", section: SSectionCFS.defaultSection)], type: SSectionData.self)
		return SSectionEditor(section: previewer.dataObjects[0]).modelContainer(previewer.container)
	} catch {
		return Text("Failed to create preview: \(error.localizedDescription)")
	}
}


