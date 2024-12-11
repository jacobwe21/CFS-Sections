import SwiftUI

public extension Color {
	/// Creates a SwiftUI `Color` from the main Color of the theme.
	/// - Parameters:
	///   - theme: the desired ColorTheme used to produce the color
	///   - shade: Specifies the light or dark version of the theme color. If `nil`, the color will slightly adjust to the light or dark device appearance.
	init(fromTheme theme: ColorTheme, shade: ColorTheme.Shade? = nil) {
		if shade.exists {
			self = theme.mainColor(shade: shade!)
		} else {
			self = theme.mainColor
		}
	}
	
	/// Does not adjust to light / dark mode
	var isLight: Bool {
		return sqrt(0.25*rgba.red**2 + 0.68*rgba.green**2 + 0.07*rgba.blue**2) > 0.5
	}
	@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
	func rgba(in environment: EnvironmentValues) -> (red: Float, green: Float, blue: Float, alpha: Float) {
		let color = self.resolve(in: environment)
		return (red: color.red, green: color.green, blue: color.blue, alpha: color.opacity)
	}
	@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
	func hsba(in environment: EnvironmentValues) -> (hue: Float, saturation: Float, brightness: Float, alpha: Float) {
		let color = self.resolve(in: environment)
		let minValue = min(color.red,color.green,color.blue)
		let maxValue = max(color.red,color.green,color.blue)
		
		var hue: Float = 0
		if abs(minValue-maxValue) < 0.000001 {
			return (hue: 0, saturation: 0, brightness: maxValue, alpha: color.opacity)
		} else if maxValue == color.red {
			hue = (color.green-color.blue)/(maxValue-minValue)
			hue = hue.truncatingRemainder(dividingBy: 6)
		} else if maxValue == color.green {
			hue = (color.blue-color.red)/(maxValue-minValue) + 2
		} else if maxValue == color.blue {
			hue = (color.red-color.green)/(maxValue-minValue) + 4
		}
		hue = hue*60/360
		let bright: Float = (minValue+maxValue)/2
		let sat: Float
		if bright == 0 || bright == 1 {
			sat = 0
		} else {
			sat = (maxValue-bright)/min(bright,1-bright)
		}
		return (hue: hue, saturation: sat, brightness: bright, alpha: color.opacity)
	}
	@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
	func hsva(in environment: EnvironmentValues) -> (hue: Float, saturation: Float, value: Float, alpha: Float) {
		let color = self.resolve(in: environment)
		let minValue = min(color.red,color.green,color.blue)
		let maxValue = max(color.red,color.green,color.blue)
		
		var hue: Float = 0
		if minValue == maxValue {
			return (hue: 0, saturation: 0, value: maxValue, alpha: color.opacity)
		} else if maxValue == color.red {
			hue = (color.green-color.blue)/(maxValue-minValue)
			hue = hue.truncatingRemainder(dividingBy: 6)
		} else if maxValue == color.green {
			hue = (color.blue-color.red)/(maxValue-minValue) + 2
		} else if maxValue == color.blue {
			hue = (color.red-color.green)/(maxValue-minValue) + 4
		}
		hue = hue*60/360
		let sat: Float
		if maxValue == 0 {
			sat = 0
		} else {
			sat = (maxValue-minValue)/maxValue
		}
		return (hue: hue, saturation: sat, value: maxValue, alpha: color.opacity)
	}
	var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		#if os(macOS)
		return NSColor(self).rgba
		#else
		return UIColor(self).rgba
		#endif
	}
	var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
	#if os(macOS)
	return NSColor(self).hsba
	#else
	return UIColor(self).hsba
	#endif
	}
}
public extension CGColor {
	var isLight: Bool {
		return sqrt(0.25*rgba.red**2 + 0.68*rgba.green**2 + 0.07*rgba.blue**2) > 0.5
	}
	var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		#if os(iOS)
		return UIColor(cgColor: self).rgba
		#elseif os(macOS)
		return NSColor(cgColor: self)!.rgba
		#endif
	}
	var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
		#if os(iOS)
		return UIColor(cgColor: self).hsba
		#elseif os(macOS)
		return NSColor(cgColor: self)!.hsba
		#endif
	}
}
#if os(iOS)
public extension UIColor {
	var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		return (red, green, blue, alpha)
	}
	var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
		var hue: CGFloat = 0
		var sat: CGFloat = 0
		var bright: CGFloat = 0
		var alpha: CGFloat = 0
		getHue(&hue, saturation: &sat, brightness: &bright, alpha: &alpha)
		return (hue, sat, bright, alpha)
	}
}
#elseif os(macOS)
public extension NSColor {
	var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		let c1 = self.usingColorSpace(.displayP3)
		let c2 = self.usingColorSpace(.deviceRGB)
		if let c = c1 {
			red = c.redComponent
			green = c.greenComponent
			blue = c.blueComponent
			alpha = c.alphaComponent
		} else if let c = c2 {
			red = c.redComponent
			green = c.greenComponent
			blue = c.blueComponent
			alpha = c.alphaComponent
		}
		return (red, green, blue, alpha)
	}
	var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
		var hue: CGFloat = 0
		var sat: CGFloat = 0
		var bright: CGFloat = 0
		var alpha: CGFloat = 0
		let c1 = self.usingColorSpace(.displayP3)
		let c2 = self.usingColorSpace(.deviceRGB)
		if let c = c1 {
			hue = c.hueComponent
			sat = c.saturationComponent
			bright = c.brightnessComponent
			alpha = c.alphaComponent
		} else if let c = c2 {
			hue = c.hueComponent
			sat = c.saturationComponent
			bright = c.brightnessComponent
			alpha = c.alphaComponent
		}
		return (hue, sat, bright, alpha)
	}
}
#endif

/// A personal collection of Colors that are used in the ColorThemes
public struct MyColors {
	public static var allCases: [Color] {
		[
			white, 	black, 			piano,		charcoal,
			wood, 	lightWood, 		darkWood, 	accentWood, accentOak,
			stone, lightStone, 	darkStone, accentStone,
			red, 	lightRed, 		darkRed, 	accentRed,
			coral, 	lightCoral, 	darkCoral, 	accentCoral,
			orange, lightOrange,	darkOrange, accentOrange,
			yellow, lightYellow,	darkYellow, accentYellow, 	gold,
			lime, 	lightLime, 		darkLime, 	accentLime, 	accentAvocado,
			green, 	lightGreen, 	darkGreen, 	accentGreen, 	accentLeaf,
			mint, 	lightMint, 		darkMint, 	accentMint, 	spearmint,
			marina, lightMarina, 	darkMarina, accentMarina,
			blue, 	lightBlue, 		darkBlue, 	accentBlue,
			indigo, lightIndigo, 	darkIndigo, accentIndigo,
			purple, lightPurple, 	darkPurple, accentPurple,
			rose, 	lightRose, 		darkRose, 	accentRose,
			pink, 	lightPink, 		darkPink, 	accentPink,
			sky, 	daylight, 		midnight,	accentSky,
			sun, 	sunrise, 		sunset, 	accentSun,		fire
		]
	}
	
	public static var white: Color { Color.white }
	public static var black: Color { Color.black }
	public static var systemBackground: Color { Color("System Background") }
	public static var systemText: Color { Color("System Text") }
	public static var uiElement: Color { Color("UI Element") }
	public static var uiElementDark: Color { Color("Dark UI Element") }
	public static var uiField: Color { Color("UI Field") }
	public static var piano: Color { Color("Piano") }
	public static var charcoal: Color { Color("Charcoal") }
	
	public static var wood: Color { Color("Wood") }
	public static var lightWood: Color { Color("Light Wood") }
	public static var darkWood: Color { Color("Dark Wood") }
	public static var accentWood: Color { Color("Accent Wood") }
	public static var accentOak: Color { Color("Accent Oak") }
	
	public static var stone: Color { Color("Stone") }
	public static var lightStone: Color { Color("Light Stone") }
	public static var darkStone: Color { Color("Dark Stone") }
	public static var accentStone: Color { Color("Accent Stone") }
	
	public static var red: Color { Color("Red") }
	public static var lightRed: Color { Color("Light Red") }
	public static var darkRed: Color { Color("Dark Red") }
	public static var accentRed: Color { Color("Accent Red") }
	
	public static var coral: Color { Color("Coral") }
	public static var lightCoral: Color { Color("Light Coral") }
	public static var darkCoral: Color { Color("Dark Coral") }
	public static var accentCoral: Color { Color("Accent Coral") }
	
	public static var orange: Color { Color("Orange") }
	public static var lightOrange: Color { Color("Light Orange") }
	public static var darkOrange: Color { Color("Dark Orange") }
	public static var accentOrange: Color { Color("Accent Orange") }
	
	public static var yellow: Color { Color("Yellow") }
	public static var lightYellow: Color { Color("Light Yellow") }
	public static var darkYellow: Color { Color("Dark Yellow") }
	public static var accentYellow: Color { Color("Accent Yellow") }
	public static var gold: Color { Color("Gold") }
	
	public static var lime: Color { Color("Lime") }
	public static var lightLime: Color { Color("Light Lime") }
	public static var darkLime: Color { Color("Dark Lime") }
	public static var accentLime: Color { Color("Accent Lime") }
	public static var accentAvocado: Color { Color("Accent Avocado") }
	
	public static var green: Color { Color("Green") }
	public static var lightGreen: Color { Color("Light Green") }
	public static var darkGreen: Color { Color("Dark Green") }
	public static var accentGreen: Color { Color("Accent Green") }
	public static var accentLeaf: Color { Color("Accent Leaf") }
	
	public static var mint: Color { Color("Mint") }
	public static var lightMint: Color { Color("Light Mint") }
	public static var darkMint: Color { Color("Dark Mint") }
	public static var accentMint: Color { Color("Accent Mint") }
	public static var spearmint: Color { Color("Spearmint") }
	
	public static var marina: Color { Color("Marina") }
	public static var lightMarina: Color { Color("Light Marine") }
	public static var darkMarina: Color { Color("Dark Marina") }
	public static var accentMarina: Color { Color("Accent Marina") }
	
	public static var blue: Color { Color("Blue") }
	public static var lightBlue: Color { Color("Light Blue") }
	public static var darkBlue: Color { Color("Dark Blue") }
	public static var accentBlue: Color { Color("Accent Blue") }
	
	public static var indigo: Color { Color("Indigo") }
	public static var lightIndigo: Color { Color("Light Indigo") }
	public static var darkIndigo: Color { Color("Dark Indigo") }
	public static var accentIndigo: Color { Color("Accent Indigo") }
	
	public static var purple: Color { Color("Purple") }
	public static var lightPurple: Color { Color("Light Purple") }
	public static var darkPurple: Color { Color("Dark Purple") }
	public static var accentPurple: Color { Color("Accent Purple") }
	
	public static var magenta: Color { Color("Magenta") }
	public static var lightMagenta: Color { Color("Light Magenta") }
	public static var darkMagenta: Color { Color("Dark Magenta") }
	public static var accentMagenta: Color { Color("Accent Magenta") }
	
	public static var pink: Color { Color("Pink") }
	public static var lightPink: Color { Color("Light Pink") }
	public static var darkPink: Color { Color("Dark Pink") }
	public static var accentPink: Color { Color("Accent Pink") }
	
	public static var rose: Color { Color("Rose") }
	public static var lightRose: Color { Color("Light Rose") }
	public static var darkRose: Color { Color("Dark Rose") }
	public static var accentRose: Color { Color("Accent Rose") }
	
	public static var sky: Color { Color("Sky") }
	public static var accentSky: Color { Color("Accent Sky") }
	public static var daylight: Color { Color("Daylight") }
	public static var midnight: Color { Color("Midnight") }
	public static var sun: Color { Color("Sun") }
	public static var fire: Color { Color("Fire") }
	public static var sunrise: Color { Color("Sunrise") }
	public static var sunset: Color { Color("Sunset") }
	public static var accentSun: Color { Color("Accent Sun") }
}

import CoreLocation

/// A theme that determines the theme for the app.
public enum ColorTheme: String, Hashable, CaseIterable, Identifiable, Codable, CustomStringConvertible {
	case red	= "Red Inferno"
	case coral	= "Rusty Coral"
	case orange = "Construction Zone"
	case wood 	= "Coffee Table"
	case yellow = "Sunshine Bananna"
	case lime	= "Avocado Lime"
	case green	= "Green Grass"
	case mint 	= "Mint Green"
	case teal 	= "Teal Marina"
	case blue 	= "Ocean Blue"
	case indigo = "Twilight Indigo"
	case purple = "Purple Royalty"
	case magenta = "Magical Magenta"
	case pink 	= "Bubble Gum"
	case rose	= "Garden Rose"
	case stone 	= "Slate Stone"
	case white 	= "White"
	case black 	= "Black"
	case piano  = "Piano Keys"
	case charcoal = "Charcoal"
	case sky 	= "Sky"
	case sun 	= "Sun"
	case invisible = "Invisible"
	case chaos	= "Chaos"
	
	public var id: String { rawValue }
	public var description: String { rawValue }
	
	public var isExclusive: Bool {
		switch self {
		case .sky, .sun, .invisible, .chaos: return true
		default: return false
		}
	}
	
	/// Color will adjust to light & dark appearance
	public var mainColor: Color {
		switch self {
		case .invisible: Color.clear
		case .chaos: Color.randomColor
		case .white: Color.white
		case .black: Color.black
		default: Color(assetName)
		}
	}
	public var textColor: Color {
		switch self {
		case .red, .coral, .blue, .indigo, .purple, .magenta, .green, .teal, .pink, .rose, .orange, .stone, .black, .chaos: return Color.white
		case .white: return Color.black
		case .charcoal: return MyColors.systemBackground
		default: return MyColors.systemText
		}
	}
	
	/// Color will NOT adjust to light & dark appearance
	public func mainColor(shade: Shade) -> Color {
		switch self {
		case .invisible: Color.clear
		case .chaos: Color.randomColor
		case .piano: shade == .light ? Color.white : Color.black
		case .white: Color.white
		case .black: Color.black
		default: Color(assetName(shade: shade))
		}
	}
	/// Color will NOT adjust to light & dark appearance
	public func textColor(shade: Shade) -> Color {
		return mainColor(shade: shade).isLight ? Color.black:Color.white
	}
	/// For choosing a light or dark version of color
	public enum Shade { case light, dark }
	
	public var accentColor: Color {
		switch self {
		case .red: 		return MyColors.accentRed
		case .coral:	return MyColors.accentCoral
		case .orange: 	return MyColors.accentOrange
		case .yellow: 	return MyColors.accentYellow
		case .lime:		return MyColors.accentLime
		case .green: 	return MyColors.accentGreen
		case .mint:		return MyColors.accentMint
		case .teal:		return MyColors.accentMarina
		case .blue: 	return MyColors.accentBlue
		case .indigo:	return MyColors.accentIndigo
		case .purple: 	return MyColors.accentPurple
		case .magenta:	return MyColors.accentMagenta
		case .pink: 	return MyColors.accentPink
		case .rose:		return MyColors.accentRose
		case .wood: 	return MyColors.accentWood
		case .stone: 	return MyColors.accentStone
		case .white: 	return MyColors.black
		case .black: 	return MyColors.white
		case .piano:	return MyColors.accentStone
		case .charcoal:	return MyColors.stone
		case .sky: 		return MyColors.accentSky
		case .sun: 		return MyColors.accentSun
		case .invisible: return Color.clear
		case .chaos: 	return Color.randomColor
		}
	}
	public var accentTextColor: Color {
		switch self {
		case .white: return MyColors.white
		case .black: return MyColors.black
		case .sky, .sun, .invisible, .charcoal:
			return MyColors.systemText
		default:
			return MyColors.systemBackground
		}
	}
	
	public var highAccentColor: Color {
		switch self {
		case .red:		return MyColors.fire
		case .coral: 	return MyColors.accentMarina
		case .teal:		return MyColors.accentWood
		case .blue: 	return MyColors.accentOrange
		case .green:	return MyColors.accentOak
		case .indigo:	return MyColors.uiElementDark
		case .magenta:	return MyColors.accentIndigo
		case .purple: 	return MyColors.gold
		case .rose: 	return MyColors.accentLeaf
		case .yellow:   return MyColors.darkWood
		case .mint:		return MyColors.spearmint
		case .lime: 	return MyColors.accentAvocado
		case .sun:		return MyColors.fire
		case .sky: 		return MyColors.accentBlue
		case .white:	return MyColors.blue
		case .black:	return MyColors.accentBlue
		case .stone, .piano, .chaos:
			return MyColors.systemText
		case .charcoal:
			return MyColors.systemBackground
		case .invisible:
			return Color.clear
		case .orange, .pink, .wood:
			return MyColors.accentStone
		}
	}
	public var highAccentTextColor: Color {
		switch self {
		case .purple: return .black
		case .green, .yellow, .charcoal: return .white
		case .invisible: return MyColors.blue
		default: return MyColors.systemBackground
		}
	}
	
	public var destructiveColor: Color {
		switch self {
		case .invisible: return Color.clear
		case .red, .rose, .coral: return MyColors.uiElementDark
		default: return MyColors.red
		}
	}
	public var destructiveTextColor: Color {
		switch self {
		case .invisible: return Color.red
		case .red, .rose, .coral: return MyColors.red
		default: return Color.white
		}
	}
	
	public var shadowRadiusForButtons: CGFloat {
		switch self {
		case .invisible: return 0
		default: return 3
		}
	}
	
	private var assetName: String {
		switch self {
		case .red: 		return "Red"
		case .coral:	return "Coral"
		case .orange: 	return "Orange"
		case .yellow: 	return "Yellow"
		case .lime: 	return "Lime"
		case .green: 	return "Green"
		case .mint:		return "Mint"
		case .teal: 	return "Marina"
		case .blue: 	return "Blue"
		case .indigo: 	return "Indigo"
		case .purple: 	return "Purple"
		case .magenta: 	return "Magenta"
		case .pink: 	return "Pink"
		case .rose:		return "Rose"
		case .wood: 	return "Wood"
		case .stone: 	return "Stone"
		case .sky:		return "Sky"
		case .sun:		return "Sun"
		case .invisible: return "System"
		case .white:	return "White"
		case .black: 	return "Black"
		case .piano: 	return "Piano"
		case .charcoal: return "Charcoal"
		case .chaos:	return "Chaos"
//			if ColorTheme.location.exists {
//				let now = Date()
//				let solar = Solar(for: now, coordinate: ColorTheme.location!)
//				guard let solar = solar else { return "Sky" }
//				if now > solar.earlySunset && now < solar.civilSunset! {
//					return "Sunset"
//				}
//				if now > solar.civilSunrise! && now < solar.lateSunrise {
//					return "Sunrise"
//				}
//			}
//			return "Sky"
		}
	}
	private func assetName(shade: Shade) -> String {
		switch self {
		case .sky:		return (shade == .light ? "Daylight":	"Midnight")
		case .sun:		return (shade == .light ? "Sunrise":	"Sunset")
		case .chaos: 	return (shade == .light ? "System Background":"System Text")
		case .invisible: 	return (shade == .light ? "System Background":"System Text")
		default: return (shade == .light ? "Light \(assetName)":"Dark \(assetName)")
		}
	}
	
	public var contrastGradients: [Gradient] {
		switch self {
		case .red: 		return [
			Gradient(colors: [MyColors.orange, MyColors.coral , MyColors.yellow]),
			Gradient(colors: [MyColors.accentOrange, MyColors.accentCoral, MyColors.accentYellow, MyColors.fire]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .coral:	return [
			Gradient(colors: [MyColors.marina, MyColors.accentGreen]),
			Gradient(colors: [MyColors.accentMint, MyColors.accentPurple]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .orange: 	return [
			Gradient(colors: [MyColors.lime, MyColors.uiField]),
			Gradient(colors: [MyColors.yellow, MyColors.uiElementDark]),
			Gradient(colors: [MyColors.blue, MyColors.lightYellow]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .yellow: 	return [
			Gradient(colors: [MyColors.accentOrange, MyColors.accentYellow]),
			Gradient(colors: [MyColors.accentWood, MyColors.accentPurple]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .lime:		return [
			Gradient(colors: [MyColors.blue, MyColors.lightYellow]),
			Gradient(colors: [MyColors.accentIndigo, MyColors.accentCoral]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .green: 	return [
			Gradient(colors: [MyColors.wood, MyColors.accentWood]),
			Gradient(colors: [MyColors.lightLime, MyColors.darkLime]),
			Gradient(colors: [MyColors.sun, MyColors.daylight]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .mint:		return [
			Gradient(colors: [MyColors.accentMarina, MyColors.accentIndigo]),
			Gradient(colors: [MyColors.yellow, MyColors.lightPurple]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .teal:		return [
			Gradient(colors: [MyColors.coral, MyColors.accentCoral]),
			Gradient(colors: [MyColors.accentIndigo, MyColors.indigo]),
			Gradient(colors: [MyColors.accentWood, MyColors.wood]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .blue: 	return [
			Gradient(colors: [MyColors.accentOrange, MyColors.orange]),
			Gradient(colors: [MyColors.accentIndigo, MyColors.marina]),
			Gradient(colors: [MyColors.accentMarina, MyColors.indigo]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .indigo:	return [
			Gradient(colors: [MyColors.magenta, MyColors.accentMagenta]),
			Gradient(colors: [MyColors.yellow, MyColors.accentCoral]),
			Gradient(colors: [self.accentColor, self.highAccentColor]),
			Gradient(colors: [MyColors.red, MyColors.orange, MyColors.yellow, MyColors.green, MyColors.blue, MyColors.purple, MyColors.pink])
		]
		case .purple: 	return [
			Gradient(colors: [MyColors.magenta, MyColors.accentMagenta]),
			Gradient(colors: [MyColors.yellow, MyColors.accentCoral]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .magenta:	return [
			Gradient(colors: [MyColors.pink, MyColors.accentPurple]),
			Gradient(colors: [MyColors.purple, MyColors.accentPink]),
			Gradient(colors: [self.accentColor, self.highAccentColor]),
			Gradient(colors: [MyColors.red, MyColors.orange, MyColors.yellow, MyColors.green, MyColors.blue, MyColors.purple, MyColors.pink]),
			Gradient(colors: [MyColors.coral, MyColors.yellow, MyColors.lime, MyColors.mint, MyColors.marina, MyColors.indigo, MyColors.magenta, MyColors.rose])
		]
		case .pink: 	return [
			Gradient(colors: [MyColors.purple, MyColors.orange]),
			Gradient(colors: [MyColors.accentPink, MyColors.yellow]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .rose:		return [
			Gradient(colors: [MyColors.daylight, MyColors.accentBlue]),
			Gradient(colors: [MyColors.lightMint, MyColors.green]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .wood: 	return [
			Gradient(colors: [MyColors.green, MyColors.accentGreen]),
			Gradient(colors: [MyColors.marina, MyColors.accentMarina]),
			Gradient(colors: [MyColors.sun, MyColors.daylight]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .stone, .black, .white: 	return [
			Gradient(colors: [.black, .white]),
			Gradient(colors: [MyColors.red, MyColors.orange, MyColors.yellow, MyColors.green, MyColors.blue, MyColors.purple, MyColors.pink]),
			Gradient(colors: [MyColors.coral, MyColors.yellow, MyColors.lime, MyColors.mint, MyColors.marina, MyColors.indigo, MyColors.magenta, MyColors.rose]),
			Gradient(colors: [MyColors.uiField, MyColors.uiElementDark]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .piano:	return [
			Gradient(colors: [.black, .white]),
			Gradient(colors: [MyColors.uiField, MyColors.uiElementDark]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .charcoal:	return [
			Gradient(colors: [.black, .white]),
			Gradient(colors: [MyColors.uiField, MyColors.uiElementDark]),
			Gradient(colors: [MyColors.sun, MyColors.fire]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .sky: 		return [
			Gradient(colors: [MyColors.accentRed, MyColors.fire, MyColors.yellow]),
			Gradient(colors: [MyColors.midnight, MyColors.daylight]),
			Gradient(colors: [MyColors.sunset, MyColors.sunrise]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .sun: 		return [
			Gradient(colors: [MyColors.accentBlue, MyColors.blue, MyColors.yellow]),
			Gradient(colors: [MyColors.midnight, MyColors.daylight]),
			Gradient(colors: [MyColors.sunset, MyColors.sunrise]),
			Gradient(colors: [self.accentColor, self.highAccentColor])
		]
		case .invisible: return [
			Gradient(colors: [.clear, MyColors.uiField])
		]
		case .chaos: 	return [
			Gradient(colors: [MyColors.red, MyColors.orange, MyColors.yellow, MyColors.green, MyColors.blue, MyColors.purple, MyColors.pink]),
			Gradient(colors: [MyColors.coral, MyColors.yellow, MyColors.lime, MyColors.mint, MyColors.marina, MyColors.indigo, MyColors.magenta, MyColors.rose])
		]
		}
	}
}


