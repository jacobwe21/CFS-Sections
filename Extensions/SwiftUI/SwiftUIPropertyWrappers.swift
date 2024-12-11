import SwiftUI

public extension AppStorage {
		
	// Default Values are provided automatically
	init(wrappedValue: Value? = nil, _ key: String) where Value == Bool {
		self.init(wrappedValue: wrappedValue ?? UserDefaults.standard.bool(forKey: key), key)
	}
	init(wrappedValue: Value? = nil, _ key: String) where Value == Int {
		self.init(wrappedValue: wrappedValue ?? UserDefaults.standard.integer(forKey: key), key)
	}
	init(wrappedValue: Value? = nil, _ key: String) where Value == Double {
		self.init(wrappedValue: wrappedValue ?? UserDefaults.standard.double(forKey: key), key)
	}
	init(wrappedValue: Value? = nil, _ key: String) where Value == String {
		self.init(wrappedValue: (wrappedValue ?? UserDefaults.standard.string(forKey: key) ?? ""), key)
	}
}

/// Place @resultBuilder before the struct, add typeAlias, and inherit the protocol
public protocol AnyResultBuilder {
	associatedtype Element
}
public extension AnyResultBuilder {
	static func buildBlock(_ components: Element...) -> [Element] {
		return components
	}
	static func buildBlock(_ components: [Element]...) -> [Element] {
		return components.flatMap { $0 }
	}
	static func buildExpression(_ element: Element) -> [Element] {
		return [element]
	}
	static func buildExpression(_ element: [Element]) -> [Element] {
		return element
	}
	static func buildOptional(_ component: [Element]?) -> [Element] {
		return component ?? []
	}
	static func buildEither(first component: [Element]) -> [Element] {
		return component
	}
	static func buildEither(second component: [Element]) -> [Element] {
		return component
	}
	static func buildArray(_ components: [[Element]]) -> [Element] {
		return components.flatMap { $0 }
	}
}

public extension Binding {
	func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
		Binding(
			get: { self.wrappedValue },
			set: { newValue in
				self.wrappedValue = newValue
				handler(newValue)
			}
		)
	}
}
//public extension Binding {
//	
//	/// Filters the array and returns the a binded filtered version of the array.
//	func filtered<A>(_ isIncluded: (Value.Element) -> Bool) -> Binding<Array<A>> where Value == Array<A> {
//		return Binding<Array<A>>(projectedValue: Binding(get: {
//			self.filter({isIncluded($0.wrappedValue)})
//		}, set: { array in
//			self.filter({isIncluded($0.wrappedValue)})
//		}))
//	}
//}
public extension Binding where Value: BidirectionalCollection, Value: RangeReplaceableCollection {

	/// Returns a `Binding` of a reversed array.
	func reversedBinding() -> Binding<Value> {
		Binding {
			Value(wrappedValue.reversed())
		} set: { newValue in
			self.wrappedValue = Value(newValue.reversed())
		}
	}
}

public extension Binding where Value == Double {
	var boundAsInt: Binding<Int> {
		get {
			Binding<Int> {
				Int(self.wrappedValue)
			} set: { newValue in
				self.wrappedValue = Double(newValue)
			}
		}
		set {
			self.wrappedValue = Double(newValue.wrappedValue)
		}
	}
}
public extension Binding where Value == Int {
	var boundAsDouble: Binding<Double> {
		get {
			Binding<Double> {
				Double(self.wrappedValue)
			} set: { newValue in
				self.wrappedValue = Int(newValue)
			}
		}
		set {
			self.wrappedValue = Int(newValue.wrappedValue)
		}
	}
}

