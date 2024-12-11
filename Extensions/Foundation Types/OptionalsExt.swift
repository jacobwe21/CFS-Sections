import Foundation

public extension Optional {
	/// Returns `true` if the value is not nil
	var exists: Bool { self != nil }
	/// Returns `true` if the value is nil
	var doesNotExist: Bool { self == nil }
	
	/// nil-coalescing operation alternative
	func orUse(_ obj: Wrapped) -> Wrapped {
		if self.exists {
			return self!
		} else {
			return obj
		}
	}
}
