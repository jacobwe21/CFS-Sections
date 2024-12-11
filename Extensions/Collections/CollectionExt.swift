import Foundation

public extension RandomAccessCollection where Self: RangeReplaceableCollection {
	func reversedRawCollection() -> Self {
		var reversedCollection = Self()

		var currentIndex = endIndex
		while currentIndex != startIndex {
			currentIndex = index(before: currentIndex)
			reversedCollection.append(self[currentIndex])
		}

		return reversedCollection
	}
}

public extension MutableCollection {
	mutating func updateEach(_ update: (inout Element) -> Void) {
		var i = startIndex
		while i != endIndex {
			update(&self[i])
			i = index(after: i)
		}
	}
	mutating func updateEach(_ updateTo: (Element) -> Element) {
		var i = startIndex
		while i != endIndex {
			self[i] = updateTo(self[i])
			i = index(after: i)
		}
	}
	
	/// Merges the elements of the collection
	func merge(combining: (Element, Element)->Element) -> Element? {
		if self.count == 1 { return self.first! }
		guard self.count > 1 else { return nil }
		var value = first!
		var i = index(after: startIndex)
		while i != endIndex {
			value = combining(value,self[i])
			i = index(after: i)
		}
		return value
	}
	/// Merges the elements of the collection
	func merge(defaultValue: Element, combining: (Element, Element)->Element) -> Element {
		if self.count == 1 { return self.first! }
		guard self.count > 1 else { return defaultValue }
		var value = first!
		var i = index(after: startIndex)
		while i != endIndex {
			value = combining(value,self[i])
			i = index(after: i)
		}
		return value
	}
}

public extension MutableCollection where Element: Equatable {
	/// Returns the next element in the sequence. If `element` is the last element, returns the first element. Returns `nil` if the provided `element` cannot be found in the collection.
	func next(after element: Element) -> Element? {
		guard let i = firstIndex(of: element) else { return nil }
		var i2 = index(after: i)
		if self.endIndex == i2 {
			i2 = self.startIndex
		}
		return self[i2]
	}
}

public extension RangeReplaceableCollection where Element: Equatable {
	/// Removes the `value` from the collection, and returns the element if found.
	@discardableResult
	mutating func remove(_ value: Element) -> Element? {
		guard let i = self.firstIndex(of: value) else { return nil }
		return self.remove(at: i)
	}
}

public extension MutableCollection where Element: Identifiable {
	/// Returns the first index where the specified value ID appears in the collection.
	func firstIndex(forID id: Element.ID) -> Self.Index? {
		guard let i = firstIndex(where: {$0.id == id}) else { return nil }
		return i
	}
}
