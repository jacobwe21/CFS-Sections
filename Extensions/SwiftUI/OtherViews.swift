import SwiftUI

// MARK: ShapeStyle
public extension ShapeStyle where Self == Color {
	static var randomColor: Color {
		Color(
			red: 	.random(in: 0.0 ... 1.0),
			green: 	.random(in: 0.0 ... 1.0),
			blue: 	.random(in: 0.0 ... 1.0)
		)
	}
}

// MARK: AnyView
public extension AnyView {
	init?<V: View>(_ view: V?) {
		guard let view = view else { return nil }
		self = AnyView(view)
	}
}

// MARK: Oriented Stacks
public struct OrientedStack<Content: View>: View {
	@Environment(\.orientation) var orientation
	let content: Content
	let reverseOrientation: Bool
	let spacing: CGFloat?
	
	public init(reverseOrientation: Bool = false, spacing: CGFloat? = nil, @ViewBuilder content: ()->Content) {
		self.content = content()
		self.reverseOrientation = reverseOrientation
		self.spacing = spacing
	}
	
	public var body: some View {
		if orientation.isLandscape && !reverseOrientation || reverseOrientation && orientation.isPortrait {
			HStack(spacing: spacing) {
				content
			}
		} else {
			VStack(spacing: spacing) {
				content
			}
		}
	}
}
public struct AxisStack<Content: View>: View {
	@Environment(\.orientation) var orientation
	let content: Content
	let axis: Axis.Set
	let spacing: CGFloat?
	
	public init(axis: Axis.Set, spacing: CGFloat? = nil, @ViewBuilder content: ()->Content) {
		self.content = content()
		self.axis = axis
		self.spacing = spacing
	}
	
	public var body: some View {
		if axis == .horizontal {
			HStack(spacing: spacing) {
				content
			}
		} else {
			VStack(spacing: spacing) {
				content
			}
		}
	}
}


// MARK: Aligned & Stacked Views
public extension HorizontalAlignment {
	private enum GroupedLayered: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat {
			context[HorizontalAlignment.center]
		}
	}
	static let groupedLayeredH = HorizontalAlignment(GroupedLayered.self)
}
public extension VerticalAlignment {
	private enum GroupedLayered: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat {
			context[VerticalAlignment.center]
		}
	}
	static let groupedLayeredV = VerticalAlignment(GroupedLayered.self)
}
public extension Alignment {
	static let groupedLayeredImages = Alignment(horizontal: .groupedLayeredH, vertical: .groupedLayeredV)
}
