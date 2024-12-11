import Foundation

public extension Int {
	init(_ bool: Bool) {
		if bool == true { self = 1 } else { self = 0 }
	}
	
//	func squared() -> Int {
//		return self.toThe(2)
//	}
//	/// Raises `self` to the `degree` specified
//	func toThe(_ degree: Int) -> Int {
//		return Int(pow(Double(self), Double(degree)))
//	}
	
	var isOdd: Bool {
		return self % 2 != 0
	}
	var isEven: Bool {
		return self % 2 == 0
	}
	
	
	/// Round to the nearest multiple of the integer using the rule provided
	/// - Parameters:
	///   - multiple: A non-negative integer that the return result is a multiple of
	///   - rule: The method for rounding to the the nearest multiple. `toNearestOrEven` will round to the nearest multiple, toward zero if the multiple is even, or away from zero otherwise.
	/// - Returns: A multiple of the the integer near the original integer
	/// - Warning: Using a negative multiple will revese the rounding rules. `toNearestOrEven` may fail to round to an even integer depending on the multiple provided.
	func round(toNearestMultipleOf multiple: Int, rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Int {
		if self.isMultiple(of: multiple) { return self }
		let q = self/multiple
		var x: Int = self
		let roundedUp = q*multiple + multiple
		let roundedDown = q*multiple - multiple
//		print("input: \(self)")
//		print("factor: \(multiple)")
//		print("q: \(q)")
//		print("q*factor: \(q*multiple)")
//		print("roundedUp: \(roundedUp)")
//		print("roundedDown: \(roundedDown)")
		switch rule {
		case .toNearestOrAwayFromZero:
			if self > 0 {
				if abs(roundedUp-self) < abs(q*multiple-self) {
					x = roundedUp
				} else if abs(roundedUp-self) > abs(q*multiple-self) {
					x = q*multiple
				} else {
					x = roundedUp
				}
			} else {
				if abs(q*multiple-self) < abs(roundedDown-self) {
					x = q*multiple
				} else if abs(q*multiple-self) > abs(roundedDown-self) {
					x = roundedDown
				} else {
					x = roundedDown
				}
			}
		case .toNearestOrEven:
			if self > 0 {
				if abs(roundedUp-self) > abs(q*multiple-self) {
					x = roundedUp
				} else if abs(roundedUp-self) < abs(q*multiple-self) {
					x = q*multiple
				} else {
					if (q*multiple).isEven {
						x = q*multiple
					} else {
						x = roundedUp
					}
				}
			} else {
				if abs(q*multiple-self) > abs(roundedDown-self) {
					x = q*multiple
				} else if abs(q*multiple-self) < abs(roundedDown-self) {
					x = roundedDown
				} else {
					if (q*multiple).isEven {
						x = q*multiple
					} else {
						x = roundedDown
					}
				}
			}
		case .up:
			if self < 0 {
				x = q*multiple
			} else {
				x = roundedUp
			}
		case .down:
			if self < 0 {
				x = roundedDown
			} else {
				x = q*multiple
			}
		case .towardZero:
			if self < 0 {
				x = q*multiple
			} else {
				x = q*multiple
			}
		case .awayFromZero:
			if self < 0 {
				x = q*multiple - multiple
			} else {
				x = q*multiple + multiple
			}
		@unknown default:
			if self < 0 {
				x = q*multiple - multiple
			} else {
				x = q*multiple + multiple
			}
		}
		return x
	}
	
	var numberOfDigits: Int {
		if self == 0 { return 1 }
		return Int(log10(Float(abs(self)))+1)
	}
}

infix operator |+: AdditionPrecedence
infix operator |-: AdditionPrecedence
public extension FixedWidthInteger where Self: SignedInteger {
	/// Adds, and if overflow occurs, `Self.max` is returned.
	static func |+ (left: Self, right: Self) -> Self {
		let (result,overflowed) = left.addingReportingOverflow(right)
		if overflowed {
			if left < 0 && right < 0 {
				return Self.min
			}
			if left < 0 {
				if abs(left) > right  {
					return Self.min
				} else {
					return Self.max
				}
			}
			if right < 0 {
				if abs(right) > left  {
					return Self.min
				} else {
					return Self.max
				}
			}
			return Self.max
		}
		return result
	}
	/// Subtracts, and if overflow occurs, `Self.min` is returned.
	static func |- (left: Self, right: Self) -> Self {
		let (result,overflowed) = left.subtractingReportingOverflow(right)
		if overflowed {
			if left < 0 {
				if right > 0 { return Self.min }
				return Self.max
			}
			if left > 0  {
				if right < 0 { return Self.max }
				return Self.min
			}
		}
		return result
	}
}
public extension FixedWidthInteger where Self: UnsignedInteger {
	/// Adds, and if overflow occurs, `Self.max` is returned.
	static func |+ (left: Self, right: Self) -> Self {
		let (result,overflowed) = left.addingReportingOverflow(right)
		if overflowed {
			return Self.max
		}
		return result
	}
	/// Subtracts, and if overflow occurs, `Self.min` is returned.
	static func |- (left: Self, right: Self) -> Self {
		let (result,overflowed) = left.subtractingReportingOverflow(right)
		if overflowed {
			return Self.min
		}
		return result
	}
}

public extension SignedNumeric {
	/// Apply this to the divisor to remove the possibility of dividing by zero.
	func oneIfZero() -> Self {
		if self == 0 {
			return 1
		} else { return self }
	}
}

public extension Double {
	
//	func roundedToDecimal(numPlaces places: Int) -> Double {
//		let multiplier = pow(10, Double(places))
//		return Darwin.round(self * multiplier) / multiplier
//	}
	
	/// Localized number formatted to specified number of decimal digits.
	func formatted(minFractionDigits: Int = 0, maxFractionDigits: Int) -> String {
		return self.formatted(FloatingPointFormatStyle().precision(.fractionLength(minFractionDigits...maxFractionDigits)))
	}
	/// Localized number formatted to specified number of decimal digits.
	func formatted(numFractionDigits: Int) -> String {
		return self.formatted(FloatingPointFormatStyle().precision(.fractionLength(numFractionDigits)))
	}
	/// Localized number formatted to specified number of significant digits.
	func formatted<R>(sigFigs: R) -> String where R : RangeExpression, R.Bound == Int {
		return self.formatted(FloatingPointFormatStyle().precision(.significantDigits(sigFigs)))
	}
	
	var zeroIfClose: Double {
		if self.isApproxEqual(to: 0, tolerance: 0.000000001) { return 0 } else { return self }
	}
	func isApproxEqual(to value: Double, tolerance: Double = 0.0000001) -> Bool {
		if abs(self-value) < tolerance { return true } else { return false }
	}
}

public extension CGFloat {
	func isApproxEqual(to value: Double, tolerance: Double = 0.0000001) -> Bool {
		if abs(self-value) < tolerance { return true } else { return false }
	}
}


public extension Array where Element: SignedInteger {
	/// Returns the average of the integers in the array
	func average() -> Double? {
		if self.isEmpty { return nil }
		if self.count <= 2 { return Double(self.first! + self.last!) / 2.0 }
		var sum: Double = Double(self[0])
		for i in 1..<self.count {
			sum += Double(self[i])
		}
		return (sum / Double(self.count))
	}
}
public extension Array where Element: FloatingPoint {
	/// Returns the average of the elements in the array
	func average() -> Element? {
		if self.isEmpty { return nil }
		if self.count <= 2 { return (self.first! + self.last!) / Element(Int(2)) }
		var sum: Element = self[0]
		for i in 1..<self.count {
			sum += self[i]
		}
		return (sum / Element(self.count))
	}
}

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}
infix operator ** : ExponentiationPrecedence
public func ** (_ base: Int, _ exp: Int) -> Int {
	return Int(pow(Double(base), Double(exp)).rounded())
}
public func ** (_ base: Double, _ exp: Double) -> Double {
  return pow(base, exp)
}
public func ** (_ base: Double, _ exp: Int) -> Double {
  return pow(base, Double(exp))
}
public func ** (_ base: Float, _ exp: Float) -> Float {
  return pow(base, exp)
}

public extension Comparable where Self:SignedNumeric {
	/// Returns either `low` or `high`, whichever is closest to `self`. Returns self if directly in the middle.
	func toNearest(low: Self, high: Self, ifEqual: Self? = nil) -> Self {
		if abs(low-self) < abs(high-self) { return low }
		if abs(high-self) < abs(low-self) { return high }
		return ifEqual ?? self
	}
	/// Returns either `low` or `high`, whichever is furthest from `self`. Returns self if directly in the middle.
	func toFurthest(low: Self, high: Self, ifEqual: Self? = nil) -> Self {
		if abs(low-self) > abs(high-self) { return low }
		if abs(high-self) > abs(low-self) { return high }
		return ifEqual ?? self
	}
	
	/// Returns a number from the list, whichever is closest to `self`. Prioritizes numbers earlier in list if directly between.
	func toNearest(_ numbers: Self...) -> Self {
		var nearest: Self = numbers.first ?? self
		for n in numbers {
			if abs(n-self) < abs(nearest-self) { nearest = n }
		}
		return nearest
	}
	/// Returns a number from the list, whichever is closest to `self`. Prioritizes numbers earlier in list if directly between.
	func toFurthest(_ numbers: Self...) -> Self {
		var furthest: Self = numbers.first ?? self
		for n in numbers {
			if abs(n-self) > abs(furthest-self) { furthest = n }
		}
		return furthest
	}
	/// Returns a number from the list, whichever is closest to `self`. Prioritizes numbers earlier in list if directly between.
	func toNearest(_ numbers: [Self]) -> Self {
		var nearest: Self = numbers.first ?? self
		for n in numbers {
			if abs(n-self) < abs(nearest-self) { nearest = n }
		}
		return nearest
	}
	/// Returns a number from the list, whichever is closest to `self`. Prioritizes numbers earlier in list if directly between.
	func toFurthest(_ numbers: [Self]) -> Self {
		var furthest: Self = numbers.first ?? self
		for n in numbers {
			if abs(n-self) > abs(furthest-self) { furthest = n }
		}
		return furthest
	}
}


