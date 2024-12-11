import Foundation

public enum ObjectSavableError: String, LocalizedError {
	case unableToEncode = "Unable to encode object into data"
	case noValue = "No data object found for the given key"
	case unableToDecode = "Unable to decode object into given type"
	public var errorDescription: String? { rawValue }
}

extension UserDefaults {
	
	public static func isSafeToStore(value: Codable) -> Bool {
		if value is NSData || value is NSDate || value is NSNumber || value is NSString {
			return true
		}
		return false
		// NSDictionary and NSArray only work with safe values
	}
	public static func isSafeToStore(value: Codable.Type) -> Bool {
		value == NSData.self || value == NSDate.self || value == NSNumber.self || value == NSString.self
		// NSDictionary and NSArray only work with safe values
	}
	
	/// Stores the given Object as NSData for the given key
	public func setCodable<Object>(_ object: Object, forKey: String) throws where Object: Codable {
		if UserDefaults.isSafeToStore(value: object) {
			set(object, forKey: forKey)
		} else {
			let encoder = JSONEncoder()
			do {
				let data = try encoder.encode(object)
				set(data, forKey: forKey)
			} catch {
				throw ObjectSavableError.unableToEncode
			}
		}
	}
	/// Gets the object stored at the key from NSData
	public func getCodable<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Codable {
		if UserDefaults.isSafeToStore(value: type) {
			if let result = object(forKey: forKey) as? Object {
				return result
			} else { throw ObjectSavableError.unableToDecode }
		} else {
			guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
			let decoder = JSONDecoder()
			do {
				let object = try decoder.decode(type, from: data)
				return object
			} catch {
				throw ObjectSavableError.unableToDecode
			}
		}
	}
}

@propertyWrapper
public struct UserDefaultsStorage<T: Codable> {
	
	/// The most up-to-date value, if available.
	public var projectedValue: T? {
		get { return try? UserDefaults.standard.getCodable(forKey: key, castTo: T.self) }
		set(newValue) {
			if newValue.doesNotExist { UserDefaults.standard.removeObject(forKey: key) }
			else {
				wrappedValue = newValue!
			}
		}
	}
	
	public var wrappedValue: T {
		didSet {
			if UserDefaults.isSafeToStore(value: wrappedValue) {
				UserDefaults.standard.set(wrappedValue, forKey: key)
			} else {
				do {
					try UserDefaults.standard.setCodable(wrappedValue, forKey: key)
				} catch {
					print(error)
				}
			}
		}
	}
	public var key: String
	
	public init(wrappedValue: T, _ key: String) {
		if !UserDefaults.isSafeToStore(value: wrappedValue) {
			do {
				let attempt = try UserDefaults.standard.getCodable(forKey: key, castTo: T.self)
				self.init(value: attempt, key: key)
			} catch {
				print(error)
				self.init(value: wrappedValue, key: key)
			}
		} else {
			self.init(value: wrappedValue, key: key)
		}
	}
	
	public init(wrappedValue: T? = nil, _ key: String) where T == Bool {
		if wrappedValue.doesNotExist {
			self.init(value: UserDefaults.standard.bool(forKey: key), key: key)
		} else {
			self.init(value: wrappedValue!, key: key)
		}
	}
	public init(wrappedValue: T? = nil, _ key: String) where T == Int {
		if wrappedValue.doesNotExist {
			self.init(value: UserDefaults.standard.integer(forKey: key), key: key)
		} else {
			self.init(value: wrappedValue!, key: key)
		}
	}
	public init(wrappedValue: T? = nil, _ key: String) where T == Double {
		if wrappedValue.doesNotExist {
			self.init(value: UserDefaults.standard.double(forKey: key), key: key)
		} else {
			self.init(value: wrappedValue!, key: key)
		}
	}
	public init(wrappedValue: T? = nil, _ key: String) where T == Float {
		if wrappedValue.doesNotExist {
			self.init(value: UserDefaults.standard.float(forKey: key), key: key)
		} else {
			self.init(value: wrappedValue!, key: key)
		}
	}
	public init(wrappedValue: T? = nil, _ key: String) where T == String {
		if wrappedValue.doesNotExist {
			self.init(value: UserDefaults.standard.string(forKey: key) ?? "", key: key)
		} else {
			self.init(value: wrappedValue!, key: key)
		}
	}
	
	private init(value: T, key: String) {
		self.wrappedValue = UserDefaults.standard.object(forKey: key) as? T ?? value
		self.key = key
	}
}
