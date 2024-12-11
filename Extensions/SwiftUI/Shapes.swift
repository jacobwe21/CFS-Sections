import SwiftUI

struct ShapesPreviews: PreviewProvider {
	static var previews: some View {
//		ZStack {
//			CircleButton().topLeft()
//
//			BasicPopover(arrowSide: .top(.mostCounterClockwise), cornerRadius: 28)
//				//.offset(x: , y: )
//				.padding(.top, 75).padding(.leading, 2)
//				.frame(minWidth: 10, maxWidth: 300, minHeight: 50, maxHeight: 400)
//				//.topLeft()
//		}
		
//		ArrowView(PositionedArrow(from: CGVector(dx: 5,dy: -50), anchorVector: CGVector(dx: 25, dy: 0), anchoredAtHead: false), color: Color.blue, fillColor: Color.red, thickness: 1, dashedLine: [], label: Text("X"))
//			.frame(width: 200, height: 200)
		
		//PosititionedArrow(from: CGVector(distance: 40, theta: Angle(degrees: 30)), anchorVector: CGVector(distance: 40, theta: Angle(degrees: -50)), anchoredAtHead: true)
		Arrow(.downAndLeft)
		
		//SlantedLine(angle: Angle(degrees: 110))
		//CircularArrow(start: Angle(degrees: 90), end: Angle(degrees: 180), clockwise: true, arrowWidth: 10, arrowheadLength: 20)
			.stroke(style: .rounded(lineWidth: 5))
			.frame(width: 300, height: 200)
			.border(.red)
		
		//Spirograph(smallerRadius: 9, largerRadius: 12, distance: 100, type: .rose).stroke(lineWidth: 2)
	}
}

public struct HalfCapsule: Shape {
	var half: Half
	public init(half: Half) {
		self.half = half
	}
	public func path(in rect: CGRect) -> Path {
		let radius = min(rect.height/2, rect.width)
		let lengthOfRect = max(0, rect.width - radius)
		
		let centerlineY = rect.height/2
		
		let start = CGPoint(x: half == .left ? rect.width:0, y: 0)
		let p2 = CGPoint(x: half == .left ? radius:lengthOfRect, y: 0)
		let center = CGPoint(x: half == .left ? radius:lengthOfRect, y: centerlineY)
		let last = CGPoint(x: half == .left ? rect.width:0, y: radius*2)
		
		return Path { path in
			path.move(to: start)
			path.addLine(to: p2)
			path.addArc(center: center, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: half == .left ? true:false)
			path.addLine(to: last)
			path.addLine(to: start)
			path.addLine(to: p2)
		}
	}
	public enum Half: String, Sendable {
		case left, right
	}
}

public struct UpperRoundedRect: Shape {
	var upperCornerRadius: CGFloat
	public init(cornerRadius: CGFloat = 20) {
		upperCornerRadius = cornerRadius
	}
	public func path(in rect: CGRect) -> Path {
		let insetWidth = rect.width - upperCornerRadius*2

		let topLeft = CGPoint(x: upperCornerRadius, y: upperCornerRadius)
		let topRight = CGPoint(x: upperCornerRadius+insetWidth, y: upperCornerRadius)
		let bottomLeft = CGPoint(x: 0, y: rect.height)
		let bottomRight = CGPoint(x: rect.width, y: rect.height)
		
		return Path { path in
			path.addArc(center: topLeft, radius: upperCornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
			path.addArc(center: topRight, radius: upperCornerRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false)
			path.addLine(to: bottomRight)
			path.addLine(to: bottomLeft)
		}
	}
}


public struct HorizontalLine: Shape {
	
	let alignment: VerticalAlignment
	let lineWidth: CGFloat
	let lineCap: CGLineCap
	let dash: [CGFloat]
	let dashPhase: CGFloat
	
	public init(alignment: VerticalAlignment = .center, lineWidth: CGFloat, lineCap: CGLineCap = .round, dash: [CGFloat] = [CGFloat](), dashPhase: CGFloat = 0) {
		self.alignment = alignment
		self.lineWidth = lineWidth
		self.lineCap = lineCap
		self.dash = dash
		self.dashPhase = dashPhase
	}
	public func path(in rect: CGRect) -> Path {
		let y: CGFloat
		
		switch alignment {
		case .top: y = 0
		case .bottom, .firstTextBaseline, .lastTextBaseline: y = rect.height
		default: y = rect.midY
		}
		
		return Path { path in
			path.move(to: CGPoint(x: 0, y: y))
			path.addLine(to: CGPoint(x: rect.width, y: y))
		}.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: lineCap, dash: dash, dashPhase: dashPhase))
	}
}

public struct VerticalLine: Shape {
	
	let alignment: HorizontalAlignment
	let lineWidth: CGFloat
	let lineCap: CGLineCap
	let dash: [CGFloat]
	let dashPhase: CGFloat
	
	public init(alignment: HorizontalAlignment = .center, lineWidth: CGFloat, lineCap: CGLineCap = .round, dash: [CGFloat] = [CGFloat](), dashPhase: CGFloat = 0) {
		self.alignment = alignment
		self.lineWidth = lineWidth
		self.lineCap = lineCap
		self.dash = dash
		self.dashPhase = dashPhase
	}
	public func path(in rect: CGRect) -> Path {
		let x: CGFloat
		
		switch alignment {
		case .leading: x = 0
		case .trailing: x = rect.width
		default: x = rect.midX
		}
		
		return Path { path in
			path.move(to: CGPoint(x: x, y: 0))
			path.addLine(to: CGPoint(x: x, y: rect.height))
		}.strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: lineCap, dash: dash, dashPhase: dashPhase))
	}
}
public struct SlantedLine: Shape {
	
	let rotation: Angle?
	let lineWidth: CGFloat?
	let lineCap: CGLineCap?
	let dash: [CGFloat]?
	let dashPhase: CGFloat?
	
	public init(angle: Angle? = nil) {
		if let angle {
			var tempAngle = angle
			while tempAngle > Angle(degrees: 90) {
				tempAngle = tempAngle-Angle(degrees: 180)
			}
			while tempAngle < Angle(degrees: -90) {
				tempAngle = tempAngle+Angle(degrees: 180)
			}
			self.rotation = tempAngle
		} else {
			self.rotation = angle
		}
		self.lineWidth = nil
		self.lineCap = nil
		self.dash = nil
		self.dashPhase = nil
	}
	public init(angle: Angle? = nil, lineWidth: CGFloat, lineCap: CGLineCap = .round, dash: [CGFloat] = [CGFloat](), dashPhase: CGFloat = 0) {
		self.rotation = angle
		self.lineWidth = lineWidth
		self.lineCap = lineCap
		self.dash = dash
		self.dashPhase = dashPhase
	}
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		if let theta = rotation?.radians {
			let point1: CGPoint
			let point2: CGPoint
			//print(theta*180/3.1415926535)
			//print(atan(rect.height/rect.width)*180/3.1415926535)
			if atan(rect.height/rect.width) > abs(theta) {
				point1 = CGPoint(x: 0, y: rect.midX*tan(theta)+rect.midY)
				point2 = CGPoint(x: rect.maxX, y: -rect.midX*tan(theta)+rect.midY)
			} else {
				point1 = CGPoint(x: rect.midY/tan(theta)+rect.midX, y: 0)
				point2 = CGPoint(x: -rect.midY/tan(theta)+rect.midX, y: rect.maxY)
			}
			path.move(to: point1)
			path.addLine(to: point2)
		} else {
			path.move(to: rect.origin)
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
		}
		
		if lineWidth.exists {
			return path.strokedPath(StrokeStyle(lineWidth: lineWidth!, lineCap: lineCap!, dash: dash!, dashPhase: dashPhase!))
		} else {
			return path
		}
	}
}

/**
 A shape that has an arrow protruding.
 https://github.com/aheze/Popovers/blob/main/Sources/Templates/Shapes.swift
 */
public struct BasicPopover: Shape {
	/// The side of the rectangle to have the arrow
	public var arrowSide: ArrowSide

	/// The shape's corner radius
	public var cornerRadius: CGFloat

	/// The arrow's width.
	public static var width = CGFloat(35)

	/// The arrow's height.
	public static var height = CGFloat(15)

	/// The corner radius for the arrow's tip.
	public static var tipCornerRadius = CGFloat(4)

	/// The inverse corner radius for the arrow's base.
	public static var edgeCornerRadius = CGFloat(7)

	/// Offset the arrow from the sides - otherwise it will overflow out of the corner radius.
	/// This is multiplied by the `cornerRadius`.
	/**
				  /\
				 /_ \
		----------     <---- Avoid this gap.
					\
		 rectangle  |
	 */
	public static var arrowSidePadding = CGFloat(1.34)

	/// Path for the triangular arrow.
	public func arrowPath() -> Path {
		let arrowHalfWidth = (BasicPopover.width / 2) * 0.6

		let arrowPath = Path { path in
			let arrowRect = CGRect(x: 0, y: 0, width: BasicPopover.width, height: BasicPopover.height)

			path.move(to: CGPoint(x: arrowRect.minX, y: arrowRect.maxY))
			path.addArc(
				tangent1End: CGPoint(x: arrowRect.midX - arrowHalfWidth, y: arrowRect.maxY),
				tangent2End: CGPoint(x: arrowRect.midX, y: arrowRect.minX),
				radius: BasicPopover.edgeCornerRadius
			)
			path.addArc(
				tangent1End: CGPoint(x: arrowRect.midX, y: arrowRect.minX),
				tangent2End: CGPoint(x: arrowRect.midX + arrowHalfWidth, y: arrowRect.maxY),
				radius: BasicPopover.tipCornerRadius
			)
			path.addArc(
				tangent1End: CGPoint(x: arrowRect.midX + arrowHalfWidth, y: arrowRect.maxY),
				tangent2End: CGPoint(x: arrowRect.maxX, y: arrowRect.maxY),
				radius: BasicPopover.edgeCornerRadius
			)
			path.addLine(to: CGPoint(x: arrowRect.maxX, y: arrowRect.maxY))
		}
		return arrowPath
	}

	/// Draw the shape.
	public func path(in rect: CGRect) -> Path {
		var arrowPath = arrowPath()
		arrowPath = arrowPath.applying(
			.init(translationX: -(BasicPopover.width / 2), y: -(BasicPopover.height))
		)

		var path = Path()
		path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

		/// Rotation transform to make the arrow hit a different side.
		let arrowTransform: CGAffineTransform

		/// Half of the rectangle's smallest side length, used for the arrow's alignment.
		let popoverRadius: CGFloat

		let alignment: ArrowSide.ArrowAlignment
		switch arrowSide {
		case let .top(arrowAlignment):
			alignment = arrowAlignment
			arrowTransform = .init(translationX: rect.midX, y: 0)
			popoverRadius = (rect.width / 2) - BasicPopover.arrowSidePadding * cornerRadius
		case let .right(arrowAlignment):
			alignment = arrowAlignment
			arrowTransform = .init(rotationAngle: .pi/2)
				.translatedBy(x: rect.midY, y: -rect.maxX)
			popoverRadius = (rect.height / 2) - BasicPopover.arrowSidePadding * cornerRadius
		case let .bottom(arrowAlignment):
			alignment = arrowAlignment
			arrowTransform = .init(rotationAngle: .pi)
				.translatedBy(x: -rect.midX, y: -rect.maxY)
			popoverRadius = (rect.width / 2) - BasicPopover.arrowSidePadding * cornerRadius
		case let .left(arrowAlignment):
			alignment = arrowAlignment
			arrowTransform = .init(rotationAngle: .pi*3/2)
				.translatedBy(x: -rect.midY, y: 0)
			popoverRadius = (rect.height / 2) - BasicPopover.arrowSidePadding * cornerRadius
		}

		switch alignment {
		case .mostCounterClockwise:
			arrowPath = arrowPath.applying(
				.init(translationX: -popoverRadius, y: 0)
			)
		case .centered:
			break
		case .mostClockwise:
			arrowPath = arrowPath.applying(
				.init(translationX: popoverRadius, y: 0)
			)
		}

		path.addPath(arrowPath, transform: arrowTransform)

		return path
	}
	public enum ArrowSide : Sendable{
		case top(ArrowAlignment), bottom(ArrowAlignment), left(ArrowAlignment), right(ArrowAlignment)
		public enum ArrowAlignment : Sendable{
			case centered, mostCounterClockwise, mostClockwise
		}
	}
}

/**
 A curved line between 2 points.
 https://github.com/aheze/Popovers/blob/main/Sources/Templates/Shapes.swift
 */
public struct CurveConnector: Shape {
	/// The start point.
	public var start: CGPoint

	/// The end point.
	public var end: CGPoint

	/// The curve's steepness.
	public var steepness = CGFloat(0.3)

	/// The curve's direction.
	public var direction = Direction.vertical

	/**
	 A curved line between 2 points.
	 - parameter start: The start point.
	 - parameter end: The end point.
	 - parameter steepness: The curve's steepness.
	 - parameter direction: The curve's direction.
	 */
	public init(
		start: CGPoint,
		end: CGPoint,
		steepness: CGFloat = CGFloat(0.3),
		direction: CurveConnector.Direction = Direction.vertical
	) {
		self.start = start
		self.end = end
		self.steepness = steepness
		self.direction = direction
	}

	/**
	 Horizontal or Vertical line.
	 */
	public enum Direction : Sendable{
		case horizontal
		case vertical
	}

	/// Allow animations. From https://www.objc.io/blog/2020/03/10/swiftui-path-animations/
	public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
		get { AnimatablePair(start.animatableData, end.animatableData) }
		set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
	}

	/// Draw the curve.
	public func path(in _: CGRect) -> Path {
		let startControlPoint: CGPoint
		let endControlPoint: CGPoint

		switch direction {
		case .horizontal:
			let curveWidth = end.x - start.x
			let curveSteepness = curveWidth * steepness
			startControlPoint = CGPoint(x: start.x + curveSteepness, y: start.y)
			endControlPoint = CGPoint(x: end.x - curveSteepness, y: end.y)
		case .vertical:
			let curveHeight = end.y - start.y
			let curveSteepness = curveHeight * steepness
			startControlPoint = CGPoint(x: start.x, y: start.y + curveSteepness)
			endControlPoint = CGPoint(x: end.x, y: end.y - curveSteepness)
		}

		var path = Path()
		path.move(to: start)
		path.addCurve(to: end, control1: startControlPoint, control2: endControlPoint)
		return path
	}
}

public struct AnimatedShapeView: View {
	
	let points: [CGPoint]
	let shapeStyle: Color
	let lineWidth: CGFloat
	let animationDuration: Double
	@State private var percentage: CGFloat = .zero
	
	public init(points: [CGPoint], color: Color, lineWidth: CGFloat, animationDuration: Double) {
		self.points = points
		self.shapeStyle = color
		self.lineWidth = lineWidth
		self.animationDuration = animationDuration
	}
  
	public var body: some View {
		GeometryReader { geometry in
			LineFromPoints(points: points)
				.trim(from: 0, to: percentage)
				.stroke(shapeStyle, lineWidth: lineWidth)
		}
		.onAppear {
			withAnimation(.linear(duration: animationDuration)) {
				self.percentage = 1.0
			}
		}
	}
	
	public func polygonShape(sides: Int, rect: CGRect) -> [CGPoint] {
		
		var paths:[CGPoint] = []
		
		let h = Double(min(rect.size.width, rect.size.height)) / 2.0
		let c = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)
		
		for side in 0...sides {
			let angle = (Double(side) * (360.0 / Double(sides))) * Double.pi / 180
			let poi = CGPoint(x: c.x + CGFloat(cos(angle) * h), y: c.y + CGFloat(sin(angle) * h))
			paths.append(poi)
		}
		return paths
	}
}

public struct LineFromPoints: Shape {
	public let points: [CGPoint]
	public init(points: [CGPoint]) {
		self.points = points
	}
	public init(points: [SIMD2<Double>]) {
		self.points = points.map({ CGPoint(x: $0.x, y: $0.y) })
	}
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: points.first!)
		for point in 1..<points.count {
			path.addLine(to: points[point])
		}
		return path
	}
}

public struct PositionedLineView<S: ShapeStyle>: View {
	
	public init(_ line: PositionedLine, color: S = MyColors.systemText, thickness: CGFloat = 2, dashedLine: [CGFloat] = [], label: Text? = nil) {
		self.line = line
		self.color = color
		self.strokeStyle = StrokeStyle(lineWidth: thickness, lineCap: .round, lineJoin: .round, dash: dashedLine)
		self.label = label
	}
	
	/// Creates an `Arrow` shape with a line thickness and fill color specified. The `label` is at the end of the arrowhead, or at the tail if arrow is `anchoredAtHead`.
	public init(_ line: PositionedLine, color: S = MyColors.systemText, strokeStyle: StrokeStyle, label: Text? = nil) {
		self.line = line
		self.color = color
		self.strokeStyle = strokeStyle
		self.label = label
	}
	
	let line: PositionedLine
	let color: S
	let strokeStyle: StrokeStyle
	let label: Text?
	
	public var body: some View {
		GeometryReader { geo in
			if #available(macOS 14.0, iOS 17.0, *) {
				ZStack {
					line
						.stroke(color, style: strokeStyle, antialiased: true)
					if let label {
						label
							.position(CGPoint())
							.offset(x: (line.anchorVector?.dx ?? 0)+line.vector.dx+10*line.vector.normalized.dx,
									y: (line.anchorVector?.dy ?? 0)+line.vector.dy+10*line.vector.normalized.dy)
					}
				}.offset(geo.size.scaled(by: 0.5))
			} else {
				ZStack {
					line
						.stroke(style: strokeStyle)
						.fill(color)
					if let label {
						label
							.position(CGPoint())
							.offset(x: (line.anchorVector?.dx ?? 0)+line.vector.dx+10*line.vector.normalized.dx,
									y: (line.anchorVector?.dy ?? 0)+line.vector.dy+10*line.vector.normalized.dy)
					}
				}.offset(geo.size.scaled(by: 0.5))
			}
		}
	}
}
public struct PositionedLine: Shape {
	/// Creates an line based on the vector provided.
	/// - Parameters:
	///   - vector: The vector describing the line from the anchor to the other point.
	///   - anchorVector: The vector from the origin of the shape to the start of the line
	public init(from vector: CGVector, anchorVector: CGVector? = nil) {
		self.vector = vector
		self.anchorVector = anchorVector
	}
	let vector: CGVector
	let anchorVector: CGVector?
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		var headPoint: CGPoint = rect.origin.translated(by: vector)
		var tailPoint: CGPoint = rect.origin
		if let anchorVector {
			headPoint.translate(by: anchorVector)
			tailPoint.translate(by: anchorVector)
		}
		path.move(to: tailPoint)
		path.addLine(to: headPoint)
		return path
	}
}

public struct PositionedArrowView<S: ShapeStyle, F: ShapeStyle>: View {
	
	/// Creates an `PossitionedArrow` shape with a line thickness and fill color specified. The `label` is at the end of the arrowhead, or at the tail if arrow is `anchoredAtHead`.
	public init(_ arrow: PositionedArrow, color: S = MyColors.systemText, fillColor: F = Color.clear, thickness: CGFloat = 2, dashedLine: [CGFloat] = [], label: Text? = nil) {
		self.arrow = arrow
		self.color = color
		self.fillColor = fillColor
		self.strokeStyle = StrokeStyle(lineWidth: thickness, lineCap: .round, lineJoin: .round, dash: dashedLine)
		self.label = label
	}
	
	/// Creates an `PosititionedArrow` shape with a line thickness and fill color specified. The `label` is at the end of the arrowhead, or at the tail if arrow is `anchoredAtHead`.
	public init(_ arrow: PositionedArrow, color: S = MyColors.systemText, fillColor: F = Color.clear, strokeStyle: StrokeStyle, label: Text? = nil) {
		self.arrow = arrow
		self.color = color
		self.fillColor = fillColor
		self.strokeStyle = strokeStyle
		self.label = label
	}
	
	let arrow: PositionedArrow
	let color: S
	let fillColor: F
	let strokeStyle: StrokeStyle
	let label: Text?
	
	public var body: some View {
		GeometryReader { geo in
			if #available(macOS 14.0, iOS 17.0, *) {
				ZStack {
					arrow
						.stroke(color, style: strokeStyle, antialiased: true)
						.fill(fillColor, style: FillStyle(eoFill: true, antialiased: true))
					if let label {
						label
							.position(CGPoint())
							.offset(x: (arrow.anchorVector?.dx ?? 0)+arrow.vector.dx+10*arrow.vector.normalized.dx,
									y: (arrow.anchorVector?.dy ?? 0)+arrow.vector.dy+10*arrow.vector.normalized.dy)
					}
				}.offset(geo.size.scaled(by: 0.5))
			} else {
				ZStack {
					arrow
						.fill(fillColor, style: FillStyle(eoFill: true, antialiased: true))
					arrow
						.stroke(style: strokeStyle)
						.fill(color)
					if let label {
						label
							.position(CGPoint())
							.offset(x: (arrow.anchorVector?.dx ?? 0)+arrow.vector.dx+10*arrow.vector.normalized.dx,
									y: (arrow.anchorVector?.dy ?? 0)+arrow.vector.dy+10*arrow.vector.normalized.dy)
					}
				}.offset(geo.size.scaled(by: 0.5))
			}
		}
	}
}
public struct PositionedArrow: Shape {
	/// Creates an arrow based on the vector provided.
	/// - Parameters:
	///   - vector: The vector describing the arrow from the anchor to the other point. If the vector is an orthogonal unit vector, it will be scaled to fill the frame.
	///   - anchorVector: The vector from the origin of the shape to the start of the arrow
	///   - anchoredAtHead: If `true`, then the arrow will be anchored at the tip/head of the arrow rather than the tail. false` by default.
	///   - arrowWidth: The width of the arrow. The width of the arrowhead will not exceed 1/4 the distance between `self.currentPoint` and `point`. 5 by default.
	///   - arrowheadLength: The length of the arrowhead. The arrowhead length will not exceed half the distance between `self.currentPoint` and `point`. 12 by default.
	public init(from vector: CGVector, anchorVector: CGVector? = nil, anchoredAtHead: Bool = false, arrowWidth: CGFloat = 5, arrowheadLength: CGFloat = 12) {
		self.vector = vector
		self.anchorVector = anchorVector
		self.anchoredAtHead = anchoredAtHead
		self.arrowWidth = arrowWidth
		self.arrowheadLength = arrowheadLength
	}
	
	/// Creates an arrow based on the arrow direction provided.
	/// - Parameters:
	///   - direction: The Arrow direction
	///   - anchorVector: The vector from the origin of the bounding rectangle (top-left) to the start of the arrow
	///   - anchoredAtHead: If `true`, then the arrow will be anchored at the tip/head of the arrow rather than the tail. false` by default.
	///   - arrowWidth: The width of the arrow. The width of the arrowhead will not exceed 1/4 the distance between `self.currentPoint` and `point`. 5 by default.
	///   - arrowheadLength: The length of the arrowhead. The arrowhead length will not exceed half the distance between `self.currentPoint` and `point`. 12 by default.
	public init(_ direction: ArrowDirection, arrowWidth: CGFloat = 5, arrowheadLength: CGFloat = 12) {
		self.vector = direction.vector
		self.anchorVector = nil
		self.anchoredAtHead = false
		self.arrowWidth = arrowWidth
		self.arrowheadLength = arrowheadLength
	}
	
	public enum ArrowDirection {
		case up, down, left, right
		var vector: CGVector {
			switch self {
			case .up: CGVector(dx: 0, dy: -1)
			case .down: CGVector(dx: 0, dy: 1)
			case .left: CGVector(dx: -1, dy: 0)
			case .right: CGVector(dx: 1, dy: 0)
			}
		}
	}
	let vector: CGVector
	let anchoredAtHead: Bool
	let anchorVector: CGVector?
	let arrowWidth: CGFloat
	let arrowheadLength: CGFloat
	
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		var headPoint: CGPoint = rect.origin.translated(by: vector)
		var tailPoint: CGPoint = rect.origin
		if vector ==|| [ArrowDirection.up.vector, ArrowDirection.down.vector, ArrowDirection.left.vector, ArrowDirection.right.vector] {
			headPoint.scale(by: CGVector(dx: rect.width, dy: rect.height))
		}
		if let anchorVector {
			headPoint.translate(by: anchorVector)
			tailPoint.translate(by: anchorVector)
		}
		if anchoredAtHead {
			swap(&headPoint, &tailPoint)
		}
		path.move(to: tailPoint)
		path.addArrow(to: headPoint, arrowWidth: arrowWidth, arrowheadLength: arrowheadLength)
		return path
	}
}
public struct Arrow: Shape {
	/// Creates an arrow based on the arrow direction provided.
	/// - Parameters:
	///   - direction: The Arrow direction
	///   - arrowWidth: The width of the arrow. The width of the arrowhead will not exceed 1/4 the distance between `self.currentPoint` and `point`. 5 by default.
	///   - arrowheadLength: The length of the arrowhead. The arrowhead length will not exceed half the distance between `self.currentPoint` and `point`. 12 by default.
	public init(_ direction: ArrowDirection, arrowWidth: CGFloat = 5, arrowheadLength: CGFloat = 12) {
		self.direction = direction
		self.arrowWidth = arrowWidth
		self.arrowheadLength = arrowheadLength
	}
	
	public enum ArrowDirection: String, Sendable {
		case up, down, left, right, upAndRight, upAndLeft, downAndRight, downAndLeft
	}
	let direction: ArrowDirection
	let arrowWidth: CGFloat
	let arrowheadLength: CGFloat
	
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		var headPoint: CGPoint
		var tailPoint: CGPoint
		switch direction {
		case .up:
			headPoint = CGPoint(x: rect.midX, y: 0)
			tailPoint = CGPoint(x: rect.midX, y: rect.maxY)
		case .down:
			headPoint = CGPoint(x: rect.midX, y: rect.maxY)
			tailPoint = CGPoint(x: rect.midX, y: 0)
		case .left:
			headPoint = CGPoint(x: 0, y: rect.midY)
			tailPoint = CGPoint(x: rect.maxX, y: rect.midY)
		case .right:
			headPoint = CGPoint(x: rect.maxX, y: rect.midY)
			tailPoint = CGPoint(x: 0, y: rect.midY)
		case .upAndRight:
			headPoint = CGPoint(x: rect.maxX, y: 0)
			tailPoint = CGPoint(x: 0, y: rect.maxY)
		case .upAndLeft:
			headPoint = CGPoint(x: 0, y: 0)
			tailPoint = CGPoint(x: rect.maxX, y: rect.maxY)
		case .downAndRight:
			headPoint = CGPoint(x: rect.maxX, y: rect.maxY)
			tailPoint = CGPoint(x: 0, y: 0)
		case .downAndLeft:
			headPoint = CGPoint(x: 0, y: rect.maxY)
			tailPoint = CGPoint(x: rect.maxX, y: 0)
		}
		path.move(to: tailPoint)
		path.addArrow(to: headPoint, arrowWidth: arrowWidth, arrowheadLength: arrowheadLength)
		return path
	}
}
public struct CircularArrow: Shape {

	/// Creates an arrow based on the arrow direction provided.
	/// - Parameters:
	///   - start: The starting angle, measured clockwise from the +x-axis
	///   - end: The ending angle, measured clockwise from the +x-axis.
	///   - clockwise: Determines wether the arrow is clockwise or counterclockwise
	///   - arrowWidth: The width of the arrow. The width of the arrowhead will not exceed 1/4 the distance between `self.currentPoint` and `point`. 5 by default.
	///   - arrowheadLength: The length of the arrowhead. The arrowhead length will not exceed half the distance between `self.currentPoint` and `point`. 12 by default.
	public init(start: Angle, end: Angle, clockwise: Bool, arrowWidth: CGFloat = 5, arrowheadLength: CGFloat = 12) {
		arrowStart = start
		arrowEnd = end
		self.clockwise = clockwise
		self.arrowWidth = arrowWidth
		self.arrowheadLength = arrowheadLength
	}
	
	let arrowWidth: CGFloat
	let arrowheadLength: CGFloat
	let arrowStart: Angle
	let arrowEnd: Angle
	let clockwise: Bool
	
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		path.addArc(center: rect.center, radius: rect.radius, startAngle: arrowStart, endAngle: arrowEnd, clockwise: clockwise)
		path.addArrowhead(direction: Angle(degrees: arrowEnd.degrees+(clockwise ? 90:-90)), arrowWidth: arrowWidth, arrowheadLength: arrowheadLength)
		return path
	}
}
public extension Path {
	/// Adds an arrow from the current point to the point specfied.
	/// - Parameters:
	///   - point: The destination of the line, to which the arrow points.
	///   - arrowWidth: The width of the arrow. The width of the arrowhead will not exceed 1/4 the distance between `self.currentPoint` and `point`. 5 by default.
	///   - arrowheadLength: The length of the arrowhead. The arrowhead length will not exceed half the distance between `self.currentPoint` and `point`. 10 by default.
	mutating func addArrow(to point: CGPoint, arrowWidth: CGFloat = 75, arrowheadLength: CGFloat = 50) {
		let initialPoint = self.currentPoint ?? CGPoint()
		let netVector = CGVector(dx: point.x-initialPoint.x, dy: point.y-initialPoint.y)
		let unitInverseVector = netVector.reversed.normalized
		let arrowheadBasePoint = point.translated(by: unitInverseVector.scaled(by: min(arrowheadLength, netVector.length*0.5)))
		let actualArrowWidth = min(arrowWidth, netVector.length*0.25)
		let arrowheadPoint1 = arrowheadBasePoint.translated(by: CGVector(distance: actualArrowWidth, theta: Angle(radians: netVector.theta-CGFloat.pi/2)))
		let arrowheadPoint2 = arrowheadBasePoint.translated(by: CGVector(distance: actualArrowWidth, theta: Angle(radians: netVector.theta+CGFloat.pi/2)))
		
		self.move(to: initialPoint)
		self.addLine(to: arrowheadBasePoint)
		self.addLine(to: arrowheadPoint1)
		self.addLine(to: point)
		self.move(to: arrowheadBasePoint)
		self.addLine(to: arrowheadPoint2)
		self.addLine(to: point)
	}
	/// Adds an arrow from the current point to the point specfied.
	/// - Parameters:
	///   - theta: The angle defining the direction in which the arrow points, measured counterclockwise from the x-axis.
	///   - arrowWidth: The width of the arrow. The width of the arrowhead will not exceed 1/4 the distance between `self.currentPoint` and `point`. 5 by default.
	///   - arrowheadLength: The length of the arrowhead. The arrowhead length will not exceed half the distance between `self.currentPoint` and `point`. 12 by default.
	mutating func addArrowhead(direction theta: Angle, arrowWidth: CGFloat = 5, arrowheadLength: CGFloat = 12) {
		let point = self.currentPoint ?? CGPoint()
		let inverseVector = CGVector(distance: arrowheadLength, theta: theta)
		let arrowheadBasePoint = point.translated(by: inverseVector)
		let actualArrowWidth = arrowWidth
		let arrowheadPoint1 = arrowheadBasePoint.translated(by: CGVector(distance: actualArrowWidth, theta: Angle(radians: theta.radians-CGFloat.pi/2)))
		let arrowheadPoint2 = arrowheadBasePoint.translated(by: CGVector(distance: actualArrowWidth, theta: Angle(radians: theta.radians+CGFloat.pi/2)))
		
		self.move(to: arrowheadBasePoint)
		self.addLine(to: arrowheadPoint1)
		self.addLine(to: point)
		self.move(to: arrowheadBasePoint)
		self.addLine(to: arrowheadPoint2)
		self.addLine(to: point)
	}
}


public struct Spirograph: Shape {
	let innerRadius: Int
	let outerRadius: Int
	let distance: Double
	let spiralType: SpiralType
	let amount: Double
	let precisionStepSize: Double
	
	public enum SpiralType: String, CaseIterable, Sendable {
		/// A type of spiral with a small circle rolling on the inside of a larger circle
		case hypotrochoid = "Hypotrochoid"
		/// A type of spiral with a small circle rolling on the outside of a larger circle
		case epitrochoid = "Epitrochoid"
		/// A type of spiral based on a sinusoid with polar coordinates and no phase angle
		case rose = "Rose"
	}
	
	
	/// Initializes a Hypotrochoid or an Epitrochoid. Stoke the shape to draw the lines.
	/// - Parameters:
	///   - smallerRadius: The radius of the smaller circle
	///   - largerRadius: The radius of the larger circle. Increases the number of petals of a rose spiral.
	///   - distance: The distance from the center of the smaller circle to the point at which a curve is drawn
	///   - type: The type of spiral
	///   - amount: The fractional quantity of the spiral drawn. 1.0 (complete) by default.
	///   - precision: The step size for drawing the spiral. Smaller increases detail but could reduce performance. 0.01 by default.
	public init(smallerRadius: Int, largerRadius: Int, distance: Double, type: SpiralType = .hypotrochoid, amount: Double = 1.0, precision stepSize: Double = 0.01) {
		self.innerRadius = smallerRadius
		self.outerRadius = largerRadius
		self.distance = distance
		self.amount = amount
		self.spiralType = type
		self.precisionStepSize = stepSize
	}
	/// Initializes a Rose spiral. Stoke the shape to draw the lines.
	/// - Parameters:
	///   - petalCount: The number of petals on the rose (if complexity = 1)
	///   - complexity: The divisor to determine the angular ratio k for the rose
	///   - amplitude: The size of the spiral
	///   - amount: The fractional quantity of the spiral drawn. 1.0 (complete) by default.
	///   - precision: The step size for drawing the spiral. Smaller increases detail but could reduce performance. 0.01 by default.
	public init(petalCount: Int, complexity: Int, amplitude: Double, amount: Double = 1.0, precision stepSize: Double = 0.01) {
		self.innerRadius = complexity
		self.outerRadius = petalCount
		self.distance = amplitude
		self.amount = amount
		self.spiralType = SpiralType.rose
		self.precisionStepSize = stepSize
	}
	
	func gcd(_ a: Int, _ b: Int) -> Double {
		var a = a
		var b = b
		while b != 0 {
			let temp = b
			b = a % b
			a = temp
		}
		return Double(a)
	}
	
	public func path(in rect: CGRect) -> Path {
		let divisor = gcd(innerRadius, outerRadius)
		let innerRadius = Double(innerRadius)
		let outerRadius = Double(outerRadius)
		var endPoint: Double
		let difference = innerRadius - outerRadius // Only applies to non-roses
		let k = outerRadius / innerRadius // Angular Frequency - Only applies to roses
		if spiralType == .rose {
			endPoint = 2*Double.pi*innerRadius*amount
		} else {
			endPoint = ceil(2*Double.pi*outerRadius/divisor)*amount
		}
		
		var path = Path()
		for theta in stride(from: 0, through: endPoint, by: precisionStepSize) {
			var x: Double
			var y: Double
			if spiralType == .rose {
				x = distance*cos(k*theta)*cos(theta)
				y = distance*cos(k*theta)*sin(theta)
			} else {
				if spiralType == .epitrochoid {
					x = difference*cos(theta) - distance*cos(theta*difference/outerRadius)
				} else {
					x = difference*cos(theta) + distance*cos(theta*difference/outerRadius)
				}
				y = difference*sin(theta) - distance*sin(theta*difference/outerRadius)
			}
			x += rect.midX
			y += rect.midY
			
			if theta == 0 {
				path.move(to: CGPoint(x: x, y: y))
			} else {
				path.addLine(to: CGPoint(x: x, y: y))
			}
		}
		return path
	}
	
}

public extension StrokeStyle {
	static func rounded(lineWidth: CGFloat = 3) -> Self {
		StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
	}
}
