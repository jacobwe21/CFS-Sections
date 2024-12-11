import SwiftUI

// MARK: View Modifers
public extension View {
	/// Applies the modifier only if device runs macOS
	func macOS<Content: View>(_ modifier: (Self)->Content) -> some View {
		#if os(macOS)
		return modifier(self)
		#else
		return self
		#endif
	}
	/// Applies the modifier only if device does not run macOS
	func notMacOS<Content: View>(_ modifier: (Self)->Content) -> some View {
		#if !os(macOS)
		return modifier(self)
		#else
		return self
		#endif
	}
	/// Applies the modifier only if device runs iOS (and not iPadOS)
	func iOS<Content: View>(_ modifier: (Self)->Content) -> some View {
		VStack {
			if EnvironmentValues().deviceOS == .iOS {
				modifier(self)
			} else {
				self
			}
		}
	}
	/// Applies the modifier only if device runs iPadOS
	func iPadOS<Content: View>(_ modifier: (Self)->Content) -> some View {
		VStack {
			if EnvironmentValues().deviceOS == .iPadOS {
				modifier(self)
			} else {
				self
			}
		}
	}
	
	// MARK: Style Wrappers
	func myClippedShapeButtonStyle<S>(theme: ColorTheme? = nil, clipShape: S, mode buttonMode: ButtonMode = .accent, hasBorder: Bool = false, padding: CGFloat? = nil) -> some View where S: InsettableShape {
		let (bColor, fColor, borderColor) = buttonMode.colors(for: theme)
		return myClippedShapeButtonStyle(color: bColor, textColor: fColor, clipShape: clipShape, shadowRadius: theme?.shadowRadiusForButtons ?? 3, border: hasBorder ? (borderColor):nil, padding: padding)
	}
	func myClippedShapeButtonStyle<S>(color: Color, textColor: Color, clipShape: S, shadowRadius: CGFloat = 3.0, border: Color? = nil, padding: CGFloat? = nil) -> some View where S: InsettableShape {
		#if os(iOS)
		let background = clipShape
			.foregroundColor(color)
			.overlay(clipShape.strokeBorder(border ?? .clear, lineWidth: border.exists ? 3:0))
		let hiddenView = self
			.padding(.all, padding)
			.imageScale(.large)
			.font(.headline)
			.background(background)
			.clipShape(clipShape)
			.hidden()
		return ZStack {
			hiddenView
			self.foregroundColor(textColor)
				.imageScale(.large)
				.font(.headline)
		}
		.background(background)
		.clipShape(clipShape)
		.shadow(radius: shadowRadius)
		.zIndex(1.0)
		#else
		return self.font(.headline).foregroundColor((color == Color.red) ? Color("MacDestructiveText"):.primary)
		#endif
	}
	func myCapsuleButtonStyle(theme: ColorTheme? = nil, mode buttonMode: ButtonMode = .accent, padding: CGFloat? = nil) -> some View {
		return self.myClippedShapeButtonStyle(theme: theme, clipShape: Capsule(), mode: buttonMode, padding: padding)
	}
	func myLongCapsuleButtonStyle(theme: ColorTheme? = nil, mode buttonMode: ButtonMode = .accent) -> some View {
		self.left().padding(.leading).myCapsuleButtonStyle(theme: theme, mode: buttonMode)
			.padding(.horizontal)
			.padding(.horizontal).padding(.horizontal)
	}
	func myRoundedButtonStyle(theme: ColorTheme? = nil, cornerRadius: CGFloat = 15, mode buttonMode: ButtonMode = .basic, padding: CGFloat? = nil) -> some View {
		return self.myClippedShapeButtonStyle(theme: theme, clipShape: RoundedRectangle(cornerRadius: cornerRadius), mode: buttonMode, padding: padding)
	}
	func myLongRoundedButtonStyle(theme: ColorTheme? = nil, cornerRadius: CGFloat = 30, mode buttonMode: ButtonMode = .accent) -> some View {
		self.left().padding(.leading).myRoundedButtonStyle(theme: theme, cornerRadius: cornerRadius, mode: buttonMode)
			.padding(.horizontal)
			.padding(.horizontal).padding(.horizontal)
	}
	
	/// a style for descriptive user interface items
	func myCapsuleUIItemStyle(backgroundColor: Color = MyColors.systemBackground.opacity(0.25), border: Color? = nil, shadowRadius: CGFloat = 0) -> some View {
		let lineWidth: CGFloat = border.exists ? 3:0
		let borderColor: Color = border ?? .clear
		let background = Capsule()
			.foregroundColor(backgroundColor)
			.if(shadowRadius > 0) { $0.shadow(radius: shadowRadius) }
			.overlay(Capsule().strokeBorder(borderColor, lineWidth: lineWidth))
		return self
			.foregroundColor(MyColors.systemText)
			.imageScale(.large)
			.padding()
			.clipShape(Capsule())
			.background(background)
	}
	/// a style for descriptive user interface items
	func myRoundedUIItemStyle(padding: Bool = true, backgroundColor: Color = MyColors.systemBackground.opacity(0.25), cornerRadius: CGFloat = 30, border: Color? = nil, shadowRadius: CGFloat = 0) -> some View {
		let lineWidth: CGFloat = border.exists ? 3:0
		let borderColor: Color = border ?? .clear
		let background = RoundedRectangle(cornerRadius: cornerRadius)
			.foregroundColor(backgroundColor)
			.if(shadowRadius > 0) { $0.shadow(radius: shadowRadius) }
			.overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(borderColor, lineWidth: lineWidth))
		return self
			.foregroundColor(MyColors.systemText)
			.imageScale(.large)
			.if(padding) { view in
				view.padding()
			}
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
			.background(background)
			.zIndex(1.0)
	}
	/// a style for descriptive user interface items
	func myUpperRoundedUIItemStyle(padding: Bool = true, backgroundColor: Color = MyColors.systemBackground.opacity(0.25), cornerRadius: CGFloat = 20) -> some View {
		let background = UpperRoundedRect(cornerRadius: cornerRadius)
			.foregroundColor(backgroundColor)
		return self
			.foregroundColor(MyColors.systemText)
			.imageScale(.large)
			.if(padding) { view in
				view.padding()
			}
			.clipShape(UpperRoundedRect(cornerRadius: cornerRadius))
			.background(background)
			.zIndex(1.0)
	}
	
	/// Applies the .frame() modifier with equal width and height
	func squareFrame(length: CGFloat) -> some View {
		self.frame(width: length, height: length)
	}
	
	
	// MARK: Positional Shortcuts
	func left(minLength length: CGFloat? = 0) -> HStack<TupleView<(Self,Spacer)>> {
		HStack(spacing: 0) {
			self
			Spacer(minLength: length)
		}
	}
	func right(minLength length: CGFloat? = 0) -> some View {
		HStack(spacing: 0) {
			Spacer(minLength: length)
			self
		}
	}
	func top(alignment: HorizontalAlignment = .center, minLength length: CGFloat? = 0) -> some View {
		VStack(alignment: alignment, spacing: 0) {
			self
			Spacer(minLength: length)
		}
	}
	func bottom(alignment: HorizontalAlignment = .center, minLength length: CGFloat? = 0) -> some View {
		VStack(alignment: alignment, spacing: 0) {
			Spacer(minLength: length)
			self
		}
	}
	func topLeft(minLength length: CGFloat? = 0) -> some View {
		VStack(spacing: 0) {
			self.left(minLength: length)
			Spacer(minLength: length)
		}
	}
	func topRight(minLength length: CGFloat? = 0) -> some View {
		VStack(spacing: 0) {
			self.right(minLength: length)
			Spacer(minLength: length)
		}
	}
	func bottomLeft(minLength length: CGFloat? = 0) -> some View {
		VStack(spacing: 0) {
			Spacer(minLength: length)
			HStack {
				self
				Spacer(minLength: length)
			}
		}
	}
	func bottomRight(minLength length: CGFloat? = 0) -> some View {
		VStack(spacing: 0) {
			Spacer(minLength: length)
			HStack {
				Spacer(minLength: length)
				self
			}
		}
	}
	
	// MARK: Expansive Space Shortcuts
	func horizontalSpace(alignment: VerticalAlignment = .center, minLength length: CGFloat? = 0) -> some View {
		HStack(alignment: alignment, spacing: 0) {
			Spacer(minLength: length)
			self
			Spacer(minLength: length)
		}
	}
	func verticalSpace(alignment: HorizontalAlignment = .center, minLength length: CGFloat? = 0) -> some View {
		VStack(alignment: alignment, spacing: 0) {
			Spacer(minLength: length)
			self
			Spacer(minLength: length)
		}
	}
	func centeredSpace(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, minLength length: CGFloat? = 0) -> some View {
		HStack(alignment: verticalAlignment, spacing: 0) {
			Spacer(minLength: length)
			VStack(alignment: horizontalAlignment, spacing: 0) {
				Spacer(minLength: length)
				self
				Spacer(minLength: length)
			}
			Spacer(minLength: length)
		}
	}
	
	func scaleBy(if isScaled: @autoclosure ()->Bool = {return true}(), _ value: CGFloat, anchor: UnitPoint = .center) -> some View {
		if isScaled() {
			return self.scaleEffect(CGSize(width: value, height: value), anchor: anchor)
		} else {
			return self.scaleEffect(CGSize(width: 1, height: 1))
		}
	}

	// MARK: Optional Overlays
	/// Shows the overlay if the `item` is not `nil`
	func optionalOverlay<Item: Hashable, Content: View>(item: Item?, removeUnderlay: Bool = false, @ViewBuilder content: (Item) -> Content) -> some View {
		ZStack {
			self.disabled(item.exists).zIndex(1.0)
			if item.exists {
				if removeUnderlay {
					MyColors.systemBackground.edgesIgnoringSafeArea(.all)
				}
				content(item!)
			}
		}.animation(.default, value: item)
	}
	/// Shows the overlay if the `item` is equal to the `tag`
	func optionalOverlay<Item: Hashable, Content: View>(item: Item, tag: Item, removeUnderlay: Bool = false, @ViewBuilder content: (Item) -> Content) -> some View {
		ZStack {
			self.disabled(item == tag).zIndex(1.0)
			if item == tag {
				if removeUnderlay {
					MyColors.systemBackground.edgesIgnoringSafeArea(.all)
				}
				content(item)
			}
		}.animation(.default, value: item)
	}
	/// Shows the overlay if `item.id` is equal to the `id`
	func optionalOverlay<Item: Identifiable, Content: View>(item: Item, id: Item.ID, removeUnderlay: Bool = false, @ViewBuilder content: (Item) -> Content) -> some View {
		ZStack {
			self.disabled(item.id == id).zIndex(1.0)
			if item.id == id {
				if removeUnderlay {
					MyColors.systemBackground.edgesIgnoringSafeArea(.all)
				}
				content(item)
			}
		}.animation(.default, value: item.id)
	}
	/// Shows the overlay if `selected` == `true`
	func optionalOverlay<Content: View>(selected: Bool, removeUnderlay: Bool = true, content: Content) -> some View {
		ZStack {
			self.disabled(selected).zIndex(1.0)
			if selected {
				if removeUnderlay {
					MyColors.systemBackground.edgesIgnoringSafeArea(.all)
				}
				content
			}
		}.animation(.default, value: selected)
	}
	/// Shows the overlay if `selected` == `true`
	func optionalOverlay<Content: View>(selected: Bool, removeUnderlay: Bool = true, @ViewBuilder content: ()->Content) -> some View {
		optionalOverlay(selected: selected, removeUnderlay: removeUnderlay, content: content())
	}
	

	/// Applies the given transform if the given condition evaluates to `true`.
	/// - Parameters:
	///   - condition: The condition to evaluate.
	///   - transform: The transform to apply to the source `View`.
	/// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
	/// - Warning: Changing the branch forces the view to redraw. Animations are not possible because view identity changes.
	func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
		VStack {
			if condition() { transform(self).id("If Conditional") } else { self.id("If Conditional") }
		}
	}
}

// MARK: Resize Image
public extension Image {
	func resize(by amount: CGFloat, aspectRatio: CGFloat? = nil) -> some View {
		self.resizable()
		.aspectRatio(aspectRatio, contentMode: .fit)
		.scaleEffect(amount, anchor: .center)
	}
	func resizeTo(width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit) -> some View {
		self.resizable()
		.aspectRatio(aspectRatio, contentMode: contentMode)
		.frame(width: width, height: height)
	}
}

// MARK: CustomColorScheme
public protocol CustomColorSchemeCompatible {
	var followSystemAppearance: Bool {get set}
	var customColorScheme: ColorScheme {get}
}
public extension View {
	func preferredColorScheme(from object: CustomColorSchemeCompatible) -> some View {
		self.preferredColorScheme(object.followSystemAppearance ? nil:object.customColorScheme)
	}
}
extension ColorScheme: Codable {
	public init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let data = try c.decode(String.self)
		switch data {
		case "light": 	self = .light
		case "dark": 	self = .dark
		default: 		self = .light
		}
	}
	public func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		switch self {
		case .light:	try c.encode("light")
		case .dark: 	try c.encode("dark")
		@unknown default: try c.encode("auto")
		}
	}
}
