import SwiftUI

public extension AnyTransition {
	
	/// A transition that inserts by moving in and out from the specified edge with opacity.
	static func moveWithOpactiy(edge: Edge) -> AnyTransition {
		.move(edge: edge).combined(with: .opacity)
	}
	
	/// A transition that inserts by moving in and out from the specified edge with scale.
//	static func moveWithModifier(edge: Edge) -> AnyTransition {
//		.move(edge: edge).combined(with: .modifier(active: , identity: ))
//	}
	
	/// A transition that inserts by moving in from the trailing edge, and removes by moving out towards the leading edge.
	static var inverseSlide: AnyTransition {
		.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
	}
	/// A transition that inserts by moving in from the bottom edge, and removes by moving out towards the leading edge.
	static var upAndOutLeft: AnyTransition {
		.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .leading))
	}
	
	/// A transition that inserts by opacity, and removes by moving down towards the bottom edge.
	static var opacityInBottomOut: AnyTransition {
		.asymmetric(insertion: .opacity, removal: .move(edge: .bottom))
	}
	
	/// A transition that inserts by scale, and removes by opacity.
	static var scaleInOpacityOut: AnyTransition {
		.asymmetric(insertion: .scale, removal: .opacity)
	}
	
	/// scale + opacity
	static var scaleAndOpacity: AnyTransition {
		.opacity.combined(with: .scale)
	}
	
	/// A scale and fly-into or fly-out of effect
	static var fly: AnyTransition {
		.modifier(active: FlyTransition(pct: 0), identity: FlyTransition(pct: 1))
	}
	
}

// https://swiftui-lab.com/advanced-transitions/
struct FlyTransition: GeometryEffect {
	var pct: Double
	
	var animatableData: Double {
		get { pct }
		set { pct = newValue }
	}
	
	func effectValue(size: CGSize) -> ProjectionTransform {

		let rotationPercent = pct
		let a = CGFloat(Angle(degrees: 90 * (1-rotationPercent)).radians)
		
		var transform3d = CATransform3DIdentity;
		transform3d.m34 = -1/max(size.width, size.height)
		
		transform3d = CATransform3DRotate(transform3d, a, 1, 0, 0)
		transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
		
		let affineTransform1 = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
		let affineTransform2 = ProjectionTransform(CGAffineTransform(scaleX: CGFloat(pct * 2), y: CGFloat(pct * 2)))
		
		if pct <= 0.5 {
			return ProjectionTransform(transform3d).concatenating(affineTransform2).concatenating(affineTransform1)
		} else {
			return ProjectionTransform(transform3d).concatenating(affineTransform1)
		}
	}
}

extension Animation {
	func `repeat`(while expression: @autoclosure ()->Bool, autoreverses: Bool = true) -> Animation {
		if expression() {
			return self.repeatForever(autoreverses: autoreverses)
		} else {
			return self
		}
	}
}
