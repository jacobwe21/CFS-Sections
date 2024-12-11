import Foundation

@propertyWrapper
public struct MakeCodable<BackingType: CodableWrapper>: Codable {
	public var wrappedValue: BackingType.Wrapped
	var storedValue: BackingType { BackingType(wrappedValue) }
	
	public init(wrappedValue: BackingType.Wrapped, _ wrapperType: BackingType.Type) {
		self.wrappedValue = wrappedValue
	}
	
	public func encode(to encoder: Encoder) throws {
		var c = encoder.singleValueContainer()
		try c.encode(storedValue)
	}
	public init(from decoder: Decoder) throws {
		let c = try decoder.singleValueContainer()
		let codedValue = try c.decode(BackingType.self)
		self.init(wrappedValue: codedValue.decode(), BackingType.self)
	}
}
public protocol CodableWrapper where Self: Codable {
	associatedtype Wrapped
	init(_ value: Wrapped)
	func decode() -> Wrapped
}

@propertyWrapper
public struct CodableViaNSCoding<T: NSObject & NSCoding>: Codable, Hashable {
	public enum NSCodingError: Error { case failedToUnarchive }

	public var wrappedValue: T

	public init(wrappedValue: T) { self.wrappedValue = wrappedValue }

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let data = try container.decode(Data.self)
		let wrappedValue = try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data)
		if let wrappedValue {
			self.wrappedValue = wrappedValue
		} else { throw NSCodingError.failedToUnarchive }
	}

	public func encode(to encoder: Encoder) throws {
		let data = try NSKeyedArchiver.archivedData(withRootObject: wrappedValue, requiringSecureCoding: Self.wrappedValueSupportsSecureCoding)
		var container = encoder.singleValueContainer()
		try container.encode(data)
	}

	private static var wrappedValueSupportsSecureCoding: Bool {
		(T.self as? NSSecureCoding.Type)?.supportsSecureCoding ?? false
	}
}
