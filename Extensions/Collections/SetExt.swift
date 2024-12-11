import Foundation

public extension Set {
	
	mutating func insertIfPresent(_ newMember: Element?) {
		if newMember != nil {
			self.insert(newMember!)
		}
	}
	mutating func removeIfPresent(_ member: Element?)  {
		if member != nil {
			self.remove(member!)
		}
	}

	func mapToArray() -> [Element] {
		return self.map({return $0})
	}
	
}

extension Set where Element: Identifiable {
	public var ids: Set<Element.ID> {
		var result = Set<Element.ID>()
		for e in self {
			result.insert(e.id)
		}
		return result
	}
}
