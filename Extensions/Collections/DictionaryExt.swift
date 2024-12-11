import Foundation

public extension Dictionary where Value: Comparable {
	
	func maxValue() -> Value? { maxElementByValue()?.value }
	func maxElementByValue() -> Element? {
		self.max { item1, item2 in
			item2.value > item1.value
		}
	}
	
	func minValue() -> Value? { minElementByValue()?.value }
	func minElementByValue() -> Element? {
		self.min { item1, item2 in
			item2.value > item1.value
			
		}
	}

	subscript(index: Key?) -> Value? {
		get {
			if index.exists { return self[index!] } else { return nil }
		}
		set(newValue) {
			if index.exists {
				self[index!] = newValue
			}
		}
	}
	
}
