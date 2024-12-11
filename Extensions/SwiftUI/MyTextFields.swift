//
//  MyTextFields.swift
//  
//
//  Created by Jacob W Esselstyn on 1/20/23.
//

import SwiftUI

public struct MyTextFieldRow: View {
	var title: String
	let description: String
	let width: CGFloat
	@Binding var text: String
	
	public init(title: String, description: String? = nil, text: Binding<String>, width: CGFloat = 120) {
		self.title = title
		self.description = description ?? title
		self.width = width
		_text = text
	}
	
	public var body: some View {
		HStack {
			if !title.isEmpty {
				Text(title)
				Spacer()
			}
			MyTextField(description, text: $text, width: width).zIndex(1.01)
		}
		.padding(.vertical, -5)
		.myCapsuleUIItemStyle()
	}
}
public struct MyTextField: View {
	let description: String
	let width: CGFloat
	@Binding var text: String
	
	public init(_ description: String = "", text: Binding<String>, width: CGFloat = 120) {
		self.description = description
		_text = text
		self.width = width
	}
	
	public var body: some View {
		TextField(description, text: $text)
			.foregroundColor(MyColors.systemText)
			.frame(width: width)
			.padding(10.0)
			.background(MyColors.uiField)
			.cornerRadius(10)
	}
}

public struct MyNumericFieldRow: View {
	var title: String
	let description: String
	let width: CGFloat
	let prompt: String
	@Binding var number: Double
	let allowNegatives: Bool
	let allowDecimals: Bool
	let submitAction: ()->Void
	
	public init(title: String, description: String = "", value: Binding<Double>, width: CGFloat = 120, allowNegatives: Bool) {
		self.title = title
		self.description = description
		self.allowNegatives = allowNegatives
		self.allowDecimals = true
		self.width = width
		prompt = ""
		_number = value
		submitAction = {}
	}

	public var body: some View {
		HStack {
			Text(title)
			Spacer()
			MyNumericField(description, value: $number, width: width)
				.onSubmit(of: .text) {
					if !allowNegatives {
						if number < 0 {
							number = -1 * number
						}
					}
				}
		}.myCapsuleUIItemStyle()
	}
}
public struct MyNumericField: View {
	let description: String
	let width: CGFloat
	@Binding var number: Double
	
	// TO-DO: Add Focus state
	
	init(_ description: String, value: Binding<Double>, width: CGFloat = 120) {
		_number = value
		self.description = description
		self.width = width
	}
	
	#if os(macOS)
	public var body: some View {
		TextField(description, value: $number, format: .number)
			.foregroundColor(MyColors.systemText)
			.frame(width: width)
			.padding(10.0)
			.background(MyColors.uiField)
			.textFieldStyle(.roundedBorder)
			.cornerRadius(10)
	}
	#else
	public var body: some View {
		TextField(description, value: $number, format: .number)
			.foregroundColor(MyColors.systemText)
			.frame(width: width)
			.padding(10.0)
			.background(MyColors.uiField)
			.textFieldStyle(.roundedBorder)
			.keyboardType(.decimalPad)
	}
	#endif
}

public extension MeasurementFormatter {
	static let shortSpecified: MeasurementFormatter = {
		var formatter = MeasurementFormatter()
		formatter.locale = Locale.current
		formatter.unitStyle = .short
		formatter.unitOptions = [.providedUnit]
		return formatter
	}()
	static let shortLocal: MeasurementFormatter = {
		var formatter = MeasurementFormatter()
		formatter.locale = Locale.current
		formatter.unitStyle = .short
		return formatter
	}()
	static let abbreviatedSpecified: MeasurementFormatter = {
		var formatter = MeasurementFormatter()
		formatter.locale = Locale.current
		formatter.unitStyle = .medium
		formatter.unitOptions = .providedUnit
		return formatter
	}()
	static let abbreviatedLocal: MeasurementFormatter = {
		var formatter = MeasurementFormatter()
		formatter.locale = Locale.current
		formatter.unitStyle = .medium
		return formatter
	}()
}
