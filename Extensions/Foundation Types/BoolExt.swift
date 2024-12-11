import Foundation

public extension Bool {
	mutating func toggle(times: Int, wait secondsBetween: Double) async {
		for _ in 0..<times {
			try? await Task.sleep(nanoseconds: UInt64(secondsBetween  * 1_000_000_000 ))
			self.toggle()
		}
	}
}

/// An alternative to using optional Bool values.
public enum ToggleState: String, CaseIterable {
	case yes = "true", no = "false", any = "any"
	var exists: Bool { self == .yes || self == .no }
}
extension Bool {
	public init?(_ state: ToggleState) {
		if let b = Bool(state.rawValue) {
			self = b
		} else {
			return nil
		}
	}
}

