import Foundation
import SwiftUI

struct Preview: PreviewProvider {
	static var previews: some View {
		BackgroundV(menuBar: MenuBar(leadingButton: CircleButton(.back, size: .small) {})) {

		}//.environment(\.colorTheme, .invisible)
	}
}

public enum ButtonMode {
	case basic, accent, highAccent, destructive, cancel
	
	public func buttonColor(for theme: ColorTheme?) -> Color {
		switch self {
		case .basic: return theme?.mainColor ?? MyColors.uiElement
		case .accent: return theme?.accentColor ?? MyColors.uiElement
		case .highAccent: return theme?.highAccentColor ?? MyColors.uiElement
		case .destructive: 
#if os(macOS)
			return Color.red
#else
			return theme?.destructiveColor ?? ColorTheme.stone.destructiveColor
#endif
		case .cancel: return theme?.highAccentColor ?? ColorTheme.stone.highAccentColor
		}
	}
	public func buttonTextColor(for theme: ColorTheme?) -> Color {
		switch self {
		case .basic: return theme?.textColor ?? MyColors.systemText
		case .accent: return theme?.accentTextColor ?? MyColors.systemText
		case .highAccent: return theme?.highAccentTextColor ?? MyColors.systemText
		case .destructive: 
#if os(macOS)
			return Color.red
#else
			return theme?.destructiveTextColor ?? ColorTheme.stone.destructiveTextColor
#endif
		case .cancel: return theme?.highAccentTextColor ?? ColorTheme.stone.highAccentTextColor
		}
	}
	public func buttonBorderColor(for theme: ColorTheme?) -> Color? {
		let borderColor: Color?
		switch self {
		case .basic:
			borderColor = theme?.accentColor
		case .accent:
			borderColor = theme?.highAccentColor
		case .highAccent, .cancel:
			borderColor = theme?.mainColor
		case .destructive:
			let theme = theme ?? .stone
			#if os(macOS)
			borderColor = nil
			#else
			borderColor = theme.destructiveTextColor
			#endif
		}
		return borderColor
	}
	public func colors(for theme: ColorTheme?) -> (backgroundColor: Color, fontColor: Color, borderColor: Color?) {
		return (buttonColor(for: theme), buttonTextColor(for: theme), buttonBorderColor(for: theme))
	}
	public var buttonRole: ButtonRole? {
		switch self {
		case .destructive: 	return .destructive
		case .cancel: 		return .cancel
		default: 			return nil
		}
	}
}

public struct CircleButton: View {
	@Environment(\.colorTheme) var colorTheme: ColorTheme
	@Environment(\.dynamicTypeSize) var typeSize
	private let systemName: String
	let labelName: LocalizedStringKey
	let buttonAction: ()->()
	private let buttonMode: ButtonMode
	let addPadding: Edge.Set?
	let customSymbol: Bool
	let size: Image.Scale
	let isDisabled: Bool
	
	public init() {
		self.systemName = "chevron.left"
		self.labelName = ""
		self.buttonAction = {}
		buttonMode = .accent
		addPadding = .all
		customSymbol = false
		size = .large
		isDisabled = false
	}
	public init(labelName: LocalizedStringKey = "", name: String, buttonMode: ButtonMode = .accent, isDisabled: Bool = false, addPadding: Edge.Set? = .all, size: Image.Scale = .large, buttonAction: @escaping ()->()) {
		self.systemName = name
		self.labelName = labelName
		self.buttonAction = buttonAction
		self.buttonMode = buttonMode
		self.addPadding = addPadding
		self.customSymbol = true
		self.size = size
		self.isDisabled = isDisabled
	}
	public init(labelName: LocalizedStringKey = "", systemName: String, buttonMode: ButtonMode = .accent, isDisabled: Bool = false, addPadding: Edge.Set? = .all, size: Image.Scale = .large, buttonAction: @autoclosure @escaping ()->()) {
		self.systemName = systemName
		self.labelName = labelName
		self.buttonAction = buttonAction
		self.buttonMode = buttonMode
		self.addPadding = addPadding
		self.customSymbol = false
		self.size = size
		self.isDisabled = isDisabled
	}
	public init(labelName: LocalizedStringKey = "", systemName: String, buttonMode: ButtonMode = .accent, isDisabled: Bool = false, addPadding: Edge.Set? = .all, size: Image.Scale = .large, buttonAction: @escaping ()->()) {
		self.init(labelName: labelName, systemName: systemName, buttonMode: buttonMode, isDisabled: isDisabled, addPadding: addPadding, size: size, buttonAction: buttonAction())
	}
	
	public init(_ specialButton: SpecialButton, isDisabled: Bool = false, addPadding: Edge.Set? = .all, size: Image.Scale = .large, buttonAction: @autoclosure @escaping ()->()) {
		self.systemName = specialButton.systemName
		self.labelName = specialButton.labelName
		self.buttonAction = buttonAction
		self.buttonMode = specialButton.buttonMode
		self.addPadding = addPadding
		customSymbol = false
		self.size = size
		self.isDisabled = isDisabled
	}
	public init(_ specialButton: SpecialButton, isDisabled: Bool = false, addPadding: Edge.Set? = .all, size: Image.Scale = .large, buttonAction: @escaping ()->()) {
		self.init(specialButton, isDisabled: isDisabled, addPadding: addPadding, size: size, buttonAction: buttonAction())
	}
	
	public var body: some View {
		#if os(iOS)
		Button(role: buttonMode.buttonRole) {
			buttonAction()
		} label: {
			VStack {
				if customSymbol {
					Image(systemName)
				} else {
					if systemName == "chevron.left" {
						Image(systemName: systemName)
							.offset(x: -2, y: 0)
					} else {
						Image(systemName: systemName)
					}
				}
			}
			.aspectRatio(1.0, contentMode: .fit)
			.if(size == .small) {
				$0.squareFrame(length: 40)
				.dynamicTypeSize(min(.xLarge,typeSize))
				.imageScale(.small)
			}
			.if(size == .medium) {
				$0.squareFrame(length: 45)
				.dynamicTypeSize(min(.xxLarge,typeSize))
				.imageScale(.medium)
			}
			.if(size == .large) {
				$0.squareFrame(length: 50)
				.dynamicTypeSize(min(.xxxLarge,typeSize))
				.imageScale(.large)
			}
			.font(.headline)
			//.foregroundColor(buttonMode.buttonTextColor(for: colorTheme))
			//.background(buttonMode.buttonColor(for: colorTheme))
			//.clipShape(Circle())
			//.shadow(radius: colorTheme.shadowRadiusForButtons)
			.zIndex(1.01)
		}
		.disabled(isDisabled).opacity(isDisabled ? 0.5:1.0)
		.if(addPadding.exists, transform: {$0.padding(addPadding ?? .all)})
		.accessibilityLabel(labelName)
		#else
		Button(action: buttonAction) {
			Label(labelName, systemImage: systemName)
				.font(.headline).foregroundColor(buttonMode == .destructive ? Color("MacDestructiveText"):.primary)
		}
		.padding()
		.disabled(isDisabled).opacity(isDisabled ? 0.5:1.0)
		#endif
	}
	
	public enum SpecialButton {
		case back, dismiss, trash, cancel
		
		var labelName: LocalizedStringKey {
			switch self {
			case .back: return "Go Back"
			case .dismiss: return "Dismiss"
			case .trash: return "Delete"
			case .cancel: return "Cancel"
			}
		}
		var systemName: String {
			switch self {
			case .back: return "chevron.left"
			case .dismiss: return "chevron.down"
			case .trash: return "trash"
			case .cancel: return "xmark.circle"
			}
		}
		var buttonMode: ButtonMode {
			switch self {
			case .dismiss: return .accent
			case .back: return .accent
			case .trash: return .destructive
			case .cancel: return .highAccent
			}
		}
	}
}

public struct CircleMenuButton<MenuContent: View>: View {
	@Environment(\.colorTheme) var colorTheme: ColorTheme
	private let systemName: String
	let labelName: String
	let menuContent: MenuContent
	private let buttonMode: ButtonMode
	let addPadding: Edge.Set?
	let customSymbol: Bool
	let smallSize: Bool

	public init(labelName: String = "", name: String, buttonMode: ButtonMode = .accent, addPadding: Edge.Set? = .all, smallSize: Bool = false, @ViewBuilder menuContent: ()->MenuContent) {
		self.systemName = name
		self.labelName = labelName
		self.menuContent = menuContent()
		self.buttonMode = buttonMode
		self.addPadding = addPadding
		self.customSymbol = true
		self.smallSize = smallSize
	}
	public init(labelName: String = "", systemName: String, buttonMode: ButtonMode = .accent, addPadding: Edge.Set? = .all, smallSize: Bool = false, @ViewBuilder menuContent: ()->MenuContent) {
		self.systemName = systemName
		self.labelName = labelName
		self.menuContent = menuContent()
		self.buttonMode = buttonMode
		self.addPadding = addPadding
		self.customSymbol = false
		self.smallSize = smallSize
	}

	public var body: some View {
		menuBody
		.menuOrder(.fixed)
		.menuStyle(.button)
		.accessibilityLabel(labelName)
	}
	var menuBody: some View {
		Menu {
			menuContent
		} label: {
			VStack {
				if customSymbol {
					Image(systemName)
				} else {
					Image(systemName: systemName)
				}
			}
#if os(iOS)
			.aspectRatio(1.0, contentMode: .fit)
			.if(smallSize) {
				$0
				.squareFrame(length: 40)
				.dynamicTypeSize(.xxxLarge)
			}
			.padding(smallSize ? 0:15)
			.font(.headline)
			.imageScale(smallSize ? .small:.large)
			.foregroundColor(buttonMode.buttonTextColor(for: colorTheme))
			.background(buttonMode.buttonColor(for: colorTheme))
			.clipShape(Circle())
			.shadow(radius: colorTheme.shadowRadiusForButtons)
			.zIndex(1.01)
#else
			.font(.headline).foregroundColor(buttonMode == .destructive ? Color("MacDestructiveText"):.primary)
#endif
		}.if(addPadding.exists, transform: {$0.padding(addPadding ?? .all)})
	}
}


public struct ClipShapeButtonLabel<S: Shape, Content: View>: View {
	@Environment(\.colorTheme) var colorTheme
	let shape: S
	let smallSize: Bool
	let content: Content
	let borderColor: Color?
	let buttonMode: ButtonMode
	let horizontalPadding: CGFloat
	var verticalPadding: CGFloat { smallSize ? 5:10 }
	
	public init(systemImage: String, shape: S, smallSize: Bool = false, horizontalPadding: CGFloat? = nil, buttonMode: ButtonMode = .accent, border: Color? = nil) where Content == Image {
		self.shape = shape
		self.smallSize = smallSize
		self.content = Image(systemName: systemImage)
		borderColor = border
		self.buttonMode = buttonMode
		self.horizontalPadding = horizontalPadding ?? (smallSize ? 10:15)
	}
	public init(shape: S, smallSize: Bool = false, horizontalPadding: CGFloat? = nil, buttonMode: ButtonMode = .accent, border: Color? = nil, @ViewBuilder content: ()->Content) {
		self.shape = shape
		self.smallSize = smallSize
		self.content = content()
		borderColor = border
		self.buttonMode = buttonMode
		self.horizontalPadding = horizontalPadding ?? (smallSize ? 10:15)
	}
	
	public var body: some View {
		let background = shape
			.foregroundColor(buttonMode.buttonColor(for: colorTheme))
			.shadow(radius: colorTheme.shadowRadiusForButtons)
			.overlay(shape.stroke(borderColor ?? .clear, lineWidth: borderColor.exists ? 3:0))
		return content
			.frame(height: smallSize ? 40:50)
			.padding(.horizontal, horizontalPadding)
			.foregroundColor(buttonMode.buttonTextColor(for: colorTheme))
			.imageScale(.large)
			.background(background)
	}
}
