//
//  SSectionTemplate.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 12/1/24.
//

import SwiftUI

struct SSectionTemplate: View {
	@Binding var sectionTemplate: SSectionCFS
	@State private var name: String = "New Section"
	
	let thicknesses: [Double] = [0.0188, 0.0283, 0.0312, 0.0346, 0.0451, 0.0566, 0.0713, 0.1017, 0.1242]
	let milThicknesses: [Double] = [18, 27, 30, 33, 43, 54, 68, 97, 118]
	let insideRadii: [Double] = [0.0844, 0.0796, 0.0782, 0.0764, 0.0712, 0.0849, 0.1069, 0.1525, 0.1863]
	
	let webDepths: [Double] = [1.625, 2.5, 3.5, 3.625, 4, 5.5, 6, 8, 10, 12, 14]
	let flangeWidths: [Double] = [1.25, 1.375, 1.625, 2, 2.5, 3, 3.5]
	let lipLengths: [Double] = [3/16, 0.375, 0.5, 0.625, 0.625, 0.625, 1]
	
	enum CFSShape: String, CaseIterable, Identifiable {
		case C, Z
		var id: String { self.rawValue }
	}
	@State private var selectedShape: CFSShape = .C
	@State private var useRoundedCorners: Bool = false
	@State private var useCenterlineDimensions: Bool = true
	@State private var thickness: Double = 0.0188
	private var radius: Double {
		if useCenterlineDimensions {
			insideRadii[thicknesses.firstIndex(of: thickness) ?? 0]
		} else {
			insideRadii[thicknesses.firstIndex(of: thickness) ?? 0] + thickness/2
		}
	}
	@State private var webDepth: Double = 1.625
	@State private var flangeWidth: Double = 1.25
	private var lipLength: Double { lipLengths[flangeWidths.firstIndex(of: flangeWidth) ?? 0] }
	
	@Environment(\.dismiss) var dismiss
	@Environment(\.modelContext) private var modelContext
	
	var body: some View {
		VStack {
			MenuBar("C/Z Template", leadingButton: CircleButton(.dismiss, buttonAction: dismiss()), trailingButton: CircleButton(labelName: "Done", systemName: "plus.circle", buttonMode: .basic, buttonAction: {
				addItem()
				dismiss()
			}))
			OrientedStack {
				VStack {
					TextField("File Name", text: $name, prompt: Text("C Shape"))
					Picker(selection: $webDepth) {
						ForEach(webDepths, id: \.self) { i in
							Text((i*100).rounded(.down).formatted(numFractionDigits: 0)).tag(i)
						}
					} label: {
						Text("Web Depth:")
					} currentValueLabel: {
						Text("\((webDepth*100).rounded(.down).formatted(numFractionDigits: 0))")
					}
					.onChange(of: webDepth) {
						sectionTemplate.updateWebDepth(useRoundedCorners: useRoundedCorners, webDepth: webDepth, lipLength: lipLength, radius: radius)
					}
					
					Picker(selection: $flangeWidth) {
						ForEach(flangeWidths, id: \.self) { i in
							Text((i*100).rounded(.down).formatted(numFractionDigits: 0)).tag(i)
						}
					} label: {
						Text("Flange Width:")
					} currentValueLabel: {
						Text("\((flangeWidth*100).rounded(.down).formatted(numFractionDigits: 0))")
					}
					.onChange(of: flangeWidth) {
						sectionTemplate.updateFlangeWidth(useRoundedCorners: useRoundedCorners, flangeWidth: flangeWidth, webDepth: webDepth, lipLength: lipLength, radius: radius)
						if selectedShape == .Z {
							sectionTemplate.switchCZtemplates(webDepth: webDepth)
						}
					}
					
					Picker(selection: $thickness) {
						ForEach(milThicknesses, id: \.self) { i in
							Text((i).rounded(.down).formatted(numFractionDigits: 0)).tag(thicknesses[milThicknesses.firstIndex(of: i) ?? 0])
						}
					} label: {
						Text("Thickness:")
					} currentValueLabel: {
						Text("\(milThicknesses[thicknesses.firstIndex(of: thickness) ?? 0].rounded(.down).formatted(numFractionDigits: 0))")
					}
					.onChange(of: thickness) {
						sectionTemplate.setAllThicknesses(to: thickness)
					}
					
					Picker(selection: $selectedShape) {
						ForEach(CFSShape.allCases) { shape in
							Text(shape.rawValue).tag(shape)
						}
					} label: {
						Text("Shape Template:")
					}
					.onChange(of: selectedShape) {
						sectionTemplate.switchCZtemplates(webDepth: webDepth)
					}
					.notMacOS {
						$0.pickerStyle(.segmented)
					}
					
					Picker(selection: $useRoundedCorners) {
						Text("Rounded").tag(true as Bool)
						Text("Sharp").tag(false as Bool)
					} label: {
						Text("Corner Type:")
					}
					.onChange(of: useRoundedCorners) {
						if useRoundedCorners { sectionTemplate.addRoundedCorners(ofRadius: radius) }
						else { sectionTemplate.removeRoundedCorners() }
					}
					.notMacOS {
						$0.pickerStyle(.segmented)
					}
					
//					if useRoundedCorners {
//						Text("Inside radius: \(insideRadii[thicknesses.firstIndex(of: thickness) ?? 0])")
//						Text("Centerline radius: \(radius)")
//					}
					
					Picker(selection: $useCenterlineDimensions) {
						Text("Centerline").tag(true as Bool)
						Text("Out-to-Out").tag(false as Bool)
					} label: {
						Text("Dimension Type")
					}
					.onChange(of: useCenterlineDimensions) {
						if useCenterlineDimensions {
							sectionTemplate.convertToCenterline(isZ: selectedShape == .Z, webDepth: webDepth, thickness: thickness, radius: radius)
						} else {
							sectionTemplate.convertToOutToOut(isZ: selectedShape == .Z, webDepth: webDepth, thickness: thickness, radius: radius)
						}
					}
					.notMacOS {
						$0.pickerStyle(.segmented)
					}
				}
				.padding()
				SSectionView(section: $sectionTemplate)
			}
		}
    }
	
	private func addItem() {
		withAnimation {
			let newItem = SSectionData(timestamp: Date(), name: name, section: sectionTemplate)
			modelContext.insert(newItem)
		}
	}
}


