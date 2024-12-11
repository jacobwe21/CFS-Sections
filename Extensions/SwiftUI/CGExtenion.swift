//
//  CGExtension.swift
//
//
//  Created by Jacob W Esselstyn on 7/6/23.
//

import SwiftUI
import CoreGraphics

public extension CGPoint {
	func rotated(by angle: Angle, about anchor: CGPoint? = nil) -> CGPoint {
		if let anchor {
			let shiftedSelf = self.offset(by: anchor)
			let rotatedShiftedSelf = shiftedSelf.rotated(by: angle)
			return rotatedShiftedSelf.translated(by: anchor)
		} else {
			let theta: Double = angle.radians
			let x2: Double = x*CoreGraphics.cos(theta) - y*CoreGraphics.sin(theta)
			let y2: Double = y*CoreGraphics.cos(theta) + x*CoreGraphics.sin(theta)
			return CGPoint(x: x2, y: y2)
		}
	}
	private func offset(by origin: CGPoint) -> CGPoint {
		return CGPoint(x: x-origin.x, y: y-origin.y)
	}
	func translated(by vector: CGPoint) -> CGPoint {
		return CGPoint(x: x+vector.x, y: y+vector.y)
	}
	func translated(by vector: CGVector) -> CGPoint {
		return CGPoint(x: x+vector.dx, y: y+vector.dy)
	}
	mutating func translate(by vector: CGVector) {
		x += vector.dx
		y += vector.dy
	}
	
	func scaled(by value: CGFloat, from anchor: CGPoint? = nil) -> CGPoint {
		if let anchor {
			let shiftedSelf = self.offset(by: anchor)
			let scaledShiftedSelf = shiftedSelf.scaled(by: value)
			return scaledShiftedSelf.translated(by: anchor)
		} else {
			return CGPoint(x: x*value, y: y*value)
		}
	}
	mutating func scale(by vector: CGVector) {
		x *= vector.dx
		y *= vector.dy
	}
	func scaled(by vector: CGVector) -> CGPoint {
		return CGPoint(x: x*vector.dx, y: y*vector.dy)
	}
}


public extension CGVector {
	
	/// Initialize a new `CGVector` of (0,0)
	init() {
		self.init(dx: 0, dy: 0)
	}
	
	/// Initialize a new `CGVector`
	/// - Parameters:
	///   - distance: The length of the vector
	///   - angle: The angle from the x-axis to the vector
	init(distance: CGFloat, theta angle: Angle) {
		let x = distance*cos(angle.radians)
		let y = distance*sin(angle.radians)
		self.init(dx: x, dy: y)
	}
	func scaled(by value: CGFloat) -> Self {
		return CGVector(dx: dx*value, dy: dy*value)
	}
	/// The angle in radians from the vector to the x-axis.
	/// Returns `atan(dy/dx)`
	var theta: CGFloat { atan(dy/dx) }
	/// Reverses the direction of the vector
	var reversed: CGVector { Self(dx: -self.dx, dy: -self.dy) }
	/// The length of the vector.
	var length: CGFloat { sqrt(pow(dx,2)+pow(dy,2)) }
	/// A new vector that represents the normalized copy of the current vector.
	var normalized: CGVector {
		let len = length
		return Self(dx: dx/len, dy: dy/len)
	}
}
extension CGVector: @retroactive AdditiveArithmetic {}
extension CGVector: @retroactive VectorArithmetic {
	public mutating func scale(by rhs: Double) {
		self.dx *= CGFloat(rhs)
		self.dy *= CGFloat(rhs)
	}
	public var magnitudeSquared: Double {
		Double(pow(dx,2)+pow(dy,2))
	}
	public static func + (lhs: CGVector, rhs: CGVector) -> CGVector {
		CGVector(dx: lhs.dx+rhs.dx, dy: lhs.dy+rhs.dy)
	}
	public static func - (lhs: CGVector, rhs: CGVector) -> CGVector {
		CGVector(dx: lhs.dx-rhs.dx, dy: lhs.dy-rhs.dy)
	}
}

public extension CGRect {
	/// The geometric center of `self`
	var center: CGPoint {
		CGPoint(x: midX, y: midY)
	}
	/// The radius of a circle enclosed by `self`
	var radius: Double {
		Double(min(width, height))/2
	}
}


public extension CGSize {
	/// self.width/2
	var midWidth: CGFloat { self.width / 2 }
	/// self.height/2
	var midHeight: CGFloat { self.height / 2 }
	/// The geometric center of `self`
	var center: CGPoint { CGPoint(x: midWidth, y: midHeight) }
	var isPortrait: Bool { self.height > self.width }
	var isLandscape: Bool { self.height < self.width }
	/// Returns the length of the diagonal through the CGSize
	var distance: Double {
		return sqrt(height**2 + width**2)
	}
	/// Returns the minimum of `width` and `height`
	var minLength: Double {
		return min(self.width, self.height)
	}
	/// Returns the maximum of `width` and `height`
	var maxLength: Double {
		return max(self.width, self.height)
	}
}
extension CGSize: @retroactive AdditiveArithmetic, @retroactive VectorArithmetic {
	public mutating func scale(by rhs: Double) {
		self.width *= rhs
		self.height *= rhs
	}
	public var magnitudeSquared: Double {
		width*width + height*height
	}
	public static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width-rhs.width, height: lhs.width-rhs.height)
	}
	public static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
		CGSize(width: lhs.width+rhs.width, height: lhs.height+rhs.height)
	}
}
