import Foundation

infix operator .~. : RangeFormationPrecedence

public extension Comparable {
	
	/// Returns `self`, or `low` or `high` if `self` is lower or higher than the given constraints.
	func clamp(low: Self, high: Self) -> Self {
		if (self > high) {
			return high
		} else if (self < low) {
			return low
		}
		return self
	}
	/// Returns `self`, or sets `self` equal to `low` or `high` if `self` is lower or higher than the given constraints.
	mutating func clamped(low: Self, high: Self)  {
		if (self > high) {
			self = high
		} else if (self < low) {
			self = low
		}
	}
	
	/// Returns a ClosedRange that always has the correct lower bound
	static func .~. (_ bound1: Self, _ bound2: Self) -> ClosedRange<Self> {
		return min(bound1,bound2)...max(bound1,bound2)
	}
	
}

public extension Comparable where Self == Int {
	/// Returns `self`, or `low` or `high` if `self` is lower or higher than the given constraints.
	func clamp(low: Self = Self.min, high: Self = Self.max) -> Self {
		if (self > high) {
			return high
		} else if (self < low) {
			return low
		}
		return self
	}
	/// Returns `self`, or sets `self` equal to `low` or `high` if `self` is lower or higher than the given constraints.
	mutating func clamped(low: Self = Self.min, high: Self = Self.max)  {
		if (self > high) {
			self = high
		} else if (self < low) {
			self = low
		}
	}
}

infix operator ==&& : ComparisonPrecedence
infix operator ==|| : ComparisonPrecedence
public extension Equatable {
	/// Returns `true` if the left item equals all of the items in the list
	static func ==&& (lhs: Self, rhs: [Self]) -> Bool {
		for item in rhs {
			if lhs != item { return false }
		}
		return true
	}
	/// Returns `true` if the left item equals any of the items in the list
	static func ==|| (lhs: Self, rhs: [Self]) -> Bool {
		for item in rhs {
			if lhs == item { return true }
		}
		return false
	}
}
