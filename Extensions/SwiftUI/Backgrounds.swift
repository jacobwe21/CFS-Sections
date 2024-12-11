import SwiftUI

public struct SystemBackground: View {
	public var body: some View {
		MyColors.systemBackground.ignoresSafeArea()
	}
}
public struct PlainBackgroundV: View {
	@Environment(\.colorTheme) var colorTheme
	let color: Color?
	public init(color: Color? = nil) {
		self.color = color
	}
	public var body: some View {
		ZStack {
			SystemBackground()
			Rectangle()
				.foregroundColor(color ?? colorTheme.mainColor).opacity(0.75)
				.ignoresSafeArea()
		}
	}
}

public protocol MenuBarProtocol: View {
	associatedtype LeftButton: View
	associatedtype RightButton: View
}
public struct MenuBar<LeftButton: View, RightButton: View>: MenuBarProtocol {
	@Environment(\.dynamicTypeSize) var dynamicTypeSize
	let menuTitle: LocalizedStringKey?
	let menuTitleNonLocalized: String?
	let leftButton: LeftButton?
	let rightButton: RightButton?
	
	public init(_ title: LocalizedStringKey? = nil, leadingButton leadButton: LeftButton, trailingButton trailButton: RightButton) {
		menuTitle = title
		menuTitleNonLocalized = nil
		leftButton = leadButton
		rightButton = trailButton
	}
	public init(_ title: LocalizedStringKey? = nil, leadingButton leadButton: LeftButton) where RightButton == EmptyView {
		menuTitle = title
		menuTitleNonLocalized = nil
		leftButton = leadButton
		rightButton = nil
	}
	public init(_ title: LocalizedStringKey? = nil, trailingButton trailButton: RightButton) where LeftButton == EmptyView {
		menuTitle = title
		menuTitleNonLocalized = nil
		leftButton = nil
		rightButton = trailButton
	}
	
	public init(nonLocalizedTitle title: String, leadingButton leadButton: LeftButton, trailingButton trailButton: RightButton) {
		menuTitle = nil
		menuTitleNonLocalized = title
		leftButton = leadButton
		rightButton = trailButton
	}
	public init(nonLocalizedTitle title: String, leadingButton leadButton: LeftButton) where RightButton == EmptyView {
		menuTitle = nil
		menuTitleNonLocalized = title
		leftButton = leadButton
		rightButton = nil
	}
	public init(nonLocalizedTitle title: String, trailingButton trailButton: RightButton) where LeftButton == EmptyView {
		menuTitle = nil
		menuTitleNonLocalized = title
		leftButton = nil
		rightButton = trailButton
	}

	public var body: some View {
		HStack(alignment: .firstTextBaseline) {
			if let leftButton {
				leftButton
			} else if let rightButton {
				rightButton.hidden()
			}
			if menuTitle.doesNotExist && menuTitleNonLocalized.doesNotExist {
				Spacer()
			} else {
				if menuTitle.doesNotExist {
					Text(menuTitleNonLocalized ?? "")
						.multilineTextAlignment(.center)
						.font(.title)
						.horizontalSpace()
						.padding(dynamicTypeSize.isAccessibilitySize ? []:.vertical)
						.zIndex(2.4)
				} else {
					Text(menuTitle!)
						.multilineTextAlignment(.center)
						.font(.title)
						.horizontalSpace()
						.padding(dynamicTypeSize.isAccessibilitySize ? []:.vertical)
						.zIndex(2.4)
				}
			}
			if let rightButton {
				rightButton
			} else if let leftButton {
				leftButton.hidden()
			}
		}
	}
}

public struct BackgroundV<Content: View, MenuBarP: MenuBarProtocol>: View {
	@Environment(\.colorTheme) var colorTheme
	@Environment(\.deviceOS) var deviceOS
	let menuBar: MenuBarP
	let content: Content
	let hasOverlay: Bool
	let color: Color?
	
	public init(menuBar: MenuBarP, color: Color? = nil, withOverlay: Bool = true, @ViewBuilder content: @escaping () -> Content) {
		self.init(menuBar: menuBar, color: color, withOverlay: withOverlay, content: content())
	}
	public init(menuBar: MenuBarP, color: Color? = nil, withOverlay: Bool = true, content: Content) {
		self.menuBar = menuBar
		self.content = content
		self.color = color
		hasOverlay = withOverlay
	}
	
	public var body: some View {
		ZStack {
			PlainBackgroundV(color: color).zIndex(-1.0)
			if hasOverlay {
				VStack(spacing: 0) {
					menuBar
					ZStack {
						UpperRoundedRect(cornerRadius: 20.0)
							.foregroundColor(color ?? colorTheme.mainColor)
							.ignoresSafeArea(edges: .bottom)
						VStack {
							if let color {
								content.foregroundColor(color.isLight ? .black:.white)
							} else {
								content.foregroundColor(colorTheme.textColor)
							}
						}
					}
				}
			} else {
				VStack(spacing: 0) {
					menuBar
					content.centeredSpace(minLength: 0)
				}
			}
		}
	}
}

public struct MySheet<Content: View>: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorTheme) var colorTheme
	@Environment(\.orientation) var orientation
	@Environment(\.deviceOS) var os
	let title: LocalizedStringKey
	let content: Content
	let scrollable: YesNoMaybe
	let scrollAxis: Axis.Set
	let padding: Edge.Set?
	
	public enum YesNoMaybe {
		case yes,no,maybe
	}
	
	public init(title: LocalizedStringKey, padding: Edge.Set? = .all, scrollable: YesNoMaybe = .maybe, scrollAxis: Axis.Set = .vertical, @ViewBuilder content: @escaping () -> Content) {
		self.title = title
		self.content = content()
		self.scrollable = scrollable
		self.scrollAxis = scrollAxis
		self.padding = padding
	}
	
	public var body: some View {
		BackgroundV(menuBar: MenuBar(title, leadingButton: CircleButton(.dismiss, buttonAction: dismiss()))) {
			switch scrollable {
			case .yes:
				ScrollView(scrollAxis) {
					content.if(padding.exists, transform: {$0.padding(padding!)})
				}.scrollDismissesKeyboard(.interactively)
			case .no: content.if(padding.exists, transform: {$0.padding(padding!)})
			case .maybe: MaybeScrollView { content }
			}
		}
	}
}
public struct MultiColumnVStack<Content: View>: View {
	let content: (Int)->Content
	let numColumns: Int
	
	/// Creates a MultiColumnVStack with the number of columns specified. numColumns is limited to 1-100.
	/// The columnIndex in the closure begins at 0.
	public init(numColumns: Int, @ViewBuilder content: @escaping (Int) -> Content) {
		self.content = content
		self.numColumns = numColumns.clamp(low: 1, high: 100)
	}

	public var body: some View {
		HStack(spacing: 0) {
			ForEach(0..<numColumns, id: \.self) { index in
				VStack(spacing: 0) {
					content(index)
				}
			}
		}
	}
}
public struct MultiRowHStack<Content: View>: View {
	let content: (Int)->Content
	let numColumns: Int
	
	/// Creates a MultiColumnVStack with the number of columns specified. numColumns is limited to 1-100.
	/// The columnIndex in the closure begins at 0.
	public init(numColumns: Int, @ViewBuilder content: @escaping (Int) -> Content) {
		self.content = content
		self.numColumns = numColumns.clamp(low: 1, high: 100)
	}
	
	public var body: some View {
		VStack(spacing: 0) {
			ForEach(0..<numColumns, id: \.self) { index in
				HStack(spacing: 0) {
					content(index)
				}
			}
		}
	}
}
