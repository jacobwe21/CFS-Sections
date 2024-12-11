import Foundation

public extension Bundle {
	
	var releaseVersionNumber: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	var buildVersionNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
	var releaseVersionNumberPretty: String {
		return "v\(releaseVersionNumber ?? "1.0.0")"
	}
	var completeVersionDescription: String {
		return "v\(releaseVersionNumber ?? "1.0.0") (\(buildVersionNumber ?? "0"))"
	}
	
	convenience init?(url: URL?) {
		if url.exists {
			self.init(url: url!)
		} else { return nil }
	}
	
	/// Use within xcode for preview assets
	func decode<T: Decodable>(_ type: T.Type,
							  from filename: String,
							  dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
							  keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
		
		guard let json = url(forResource: filename, withExtension: nil) else {
			fatalError("Failed to locate \(filename) in app bundle.")
		}

		guard let jsonData = try? Data(contentsOf: json) else {
			fatalError("Failed to load \(filename) from app bundle.")
		}

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = dateDecodingStrategy
		decoder.keyDecodingStrategy = keyDecodingStrategy
		
		guard let result = try? decoder.decode(T.self, from: jsonData) else {
			fatalError("Failed to decode \(filename) from app bundle.")
		}

		return result
	}
	
}
