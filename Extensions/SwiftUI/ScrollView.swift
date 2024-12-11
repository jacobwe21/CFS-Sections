import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
public struct StackingScrollView<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
	
	@State private var viewIsTooLarge = false
	@State private var contentSize = CGSize()
	@Environment(\.orientation) var orientation
	let axes: Axis.Set
	let showIndicators: ScrollIndicatorVisibility
	let addPadding: Edge.Set?
	let padding: CGFloat
	let content: (Data.Element) -> Content
	let data: Data
	let keypath: KeyPath<Data.Element, ID>
	
	public init(data: Data, id: KeyPath<Data.Element, ID>, axes: Axis.Set = .vertical, showIndicators: ScrollIndicatorVisibility = .automatic, addPadding: Edge.Set? = .all, padding: CGFloat = 20, animationCompatible: Bool = false, @ViewBuilder content: @escaping (Data.Element) -> Content) {
		self.axes = axes
		self.showIndicators = showIndicators
		self.addPadding = addPadding
		self.padding = padding
		self.content = content
		keypath = id
		self.data = data
	}
	public init(data: Data, axes: Axis.Set = .vertical, showIndicators: ScrollIndicatorVisibility = .automatic, addPadding: Edge.Set? = .all, padding: CGFloat = 20, animationCompatible: Bool = false, @ViewBuilder content: @escaping (Data.Element) -> Content) where Data.Element: Identifiable, Data.Element.ID == ID {
		self.axes = axes
		self.showIndicators = showIndicators
		self.addPadding = addPadding
		self.padding = padding
		self.content = content
		keypath = \.id
		self.data = data
	}

	public var body: some View {
		ScrollViewReader { reader in
			ScrollView(axes) {
				ForEach(data, id: keypath) { element in
					content(element)
				}
			}
			.if(addPadding.exists, transform: { v in
				v.contentMargins(addPadding!, edgeInsets, for: .automatic)
			})
			.scrollIndicators(.automatic, axes: axes)
			.scrollIndicatorsFlash(onAppear: true)
			.scrollPosition(id: .constant(""))
		}
	}
	var edgeInsets: EdgeInsets {
		EdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
	}
}

/// Creates a scrollable view only if the view is too large
public struct MaybeScrollView<Content: View>: View {
	@State private var viewIsTooLarge = false
	@State private var contentSize = CGSize()
	@Environment(\.orientation) var orientation
	let axes: Axis.Set
	let showIndicators: Bool
	let addPadding: Edge.Set?
	let padding: CGFloat
	let content: Content
	
	public init(axes: Axis.Set = .vertical, showIndicators: Bool = true, addPadding: Edge.Set? = .all, padding: CGFloat = 20, content: Content) {
		self.axes = axes
		self.showIndicators = showIndicators
		self.addPadding = addPadding
		self.padding = padding
		self.content = content
	}
	
	public init(axes: Axis.Set = .vertical, showIndicators: Bool = true, addPadding: Edge.Set? = .all, padding: CGFloat = 20, @ViewBuilder content: ()->Content) {
		self.axes = axes
		self.showIndicators = showIndicators
		self.addPadding = addPadding
		self.padding = padding
		self.content = content()
	}
	
	public var body: some View {
		ViewThatFits {
			VStack(spacing: 0) {
				if axes == .vertical {
					VStack {
						content
						Spacer()
					}.if(addPadding.exists) { $0.padding(addPadding!, padding) }
				} else {
					Spacer(minLength: 0)
					HStack {
						content
					}.if(addPadding.exists) { $0.padding(addPadding!, padding) }
					Spacer(minLength: 0)
				}
			}
			scrollViewWithKeyboardDismiss
		}
	}
	
	var scrollViewWithKeyboardDismiss: some View {
		ScrollView(axes, showsIndicators: showIndicators) {
			innerBody
		}.scrollDismissesKeyboard(.interactively)
	}
	private var innerBody: some View {
		VStack(spacing: 0) {
			if axes == .vertical {
				VStack { content }
					.if(addPadding.exists) { $0.padding(addPadding!, padding) }
			} else {
				HStack { content }
					.if(addPadding.exists) { $0.padding(addPadding!, padding) }
			}
		}
	}
}
