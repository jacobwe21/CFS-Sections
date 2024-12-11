import Foundation
import SwiftUI

public extension Array {
	
	/// Duplicates the array `n` times
	static func * (array: Array<Element>, n: Int) -> Self {
		var partialResult = [Array<Element>]()
		for _ in 1...n {
			partialResult.append(array)
		}
		return partialResult.flatMap { $0 }
	}
	
	mutating func append(_ element: Element, if testCondition: (Element)->Bool) {
		if testCondition(element) { self.append(element) }
	}
	mutating func append(_ element: Element, if testCondition: @autoclosure ()->Bool) {
		if testCondition() { self.append(element) }
	}
	
	/// Returns the array subset with the range of indices provided.
	func subrange(_ range: Range<Index>) -> Self {
		if range.lowerBound >= self.endIndex { return [] }
		if range.upperBound >= self.endIndex {
			return self[Range(uncheckedBounds: (range.lowerBound,self.endIndex-1))].map({$0})
		} else {
			return self[range].map({$0})
		}
	}
	/// Returns the array subset with the range of indices provided.
	func subrange(_ closedRange: ClosedRange<Index>) -> Self {
		if closedRange.lowerBound >= self.endIndex { return [] }
		if closedRange.upperBound >= self.endIndex {
			return self[ClosedRange(uncheckedBounds: (closedRange.lowerBound,self.endIndex-1))].map({$0})
		} else {
			return self[closedRange].map({$0})
		}
	}
	
	enum ArrayError: Error {
		case couldNotUpdate
	}
}

public extension Array where Element: Identifiable {
	
	var ids: [Element.ID] { self.map({$0.id}) }
	
	@discardableResult
	mutating func removeFirst(ofID id: Element.ID) -> Element? {
		if let index = self.firstIndex(forID: id) {
			let x = self.remove(at: index)
			return x
		}
		return nil
	}
	/// Removes the first item in the collection matching the `id` of the element
	func removingFirst(ofID id: Element.ID) -> Self {
		var copy = self
		if let index = self.firstIndex(forID: id) {
			copy.remove(at: index)
		}
		return copy
	}
	
	func removingDuplicateIDs() -> [Element] {
		var addedDict = [Element.ID: Bool]()
		return self.filter {
			addedDict.updateValue(true, forKey: $0.id) == nil
		}
	}
	mutating func removeDuplicateIDs() {
		self = self.removingDuplicateIDs()
	}
}
extension Array where Element: Identifiable, Element.ID == String {
	public var mergedID: String {
		var s = ""
		for item in self {
			s.append(item.id)
		}
		return s
	}
}
extension Array where Element: Identifiable, Element.ID == UUID {
	subscript(id: Element.ID) -> Element? {
		get {
			guard let i = self.firstIndex(forID: id) else {return nil}
			return self[i]
		}
		set(newValue) {
			let index = self.firstIndex { $0.id == id }
			if index.exists {
				if newValue.exists {
					self[index!] = newValue!
				} else {
					self.remove(at: index!)
				}
			} else {
				if newValue.exists {
					self.append(newValue!)
				}
			}
		}
	}
}

public extension Array where Element: Equatable {
	/// Useful for getting a SwiftUI binding
	func firstElement(matching element: Element) -> Element? {
		guard let i = self.firstIndex(of: element) else {return nil}
		return self[i]
	}
	mutating func set(value: Element, for element: Element) throws {
		guard let i = self.firstIndex(of: element) else { throw ArrayError.couldNotUpdate }
		self[i] = value
	}
}
public extension Array where Element: Hashable {
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()
		return self.filter {
			addedDict.updateValue(true, forKey: $0) == nil
		}
	}
	mutating func removeDuplicates() {
		self = self.removingDuplicates()
	}
}

