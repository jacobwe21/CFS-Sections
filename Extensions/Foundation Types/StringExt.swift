import Foundation

public extension String {
	
	static func * (lhs: String, rhs: Int) -> String {
		var str = ""
		if rhs > 0 {
			for _ in 0..<rhs {
				str.append(lhs)
			}
		} else if rhs < 0 {
			for _ in rhs..<0 {
				str.append(contentsOf: lhs.reversed())
			}
		}
		return str
	}
	
	var wordCount: Int {
		let regex = try? NSRegularExpression(pattern: "\\w+")
		return regex?.numberOfMatches(in: self, range: NSRange(location: 0, length: self.utf16.count)) ?? 0
	}
	var containsNoWhiteSpace: Bool {
		let whitespace = NSCharacterSet.whitespaces
		return rangeOfCharacter(from: whitespace, options: String.CompareOptions.literal, range: nil) == nil
	}
	var containsOnlyDigits: Bool {
		let notDigits = NSCharacterSet.decimalDigits.inverted
		return rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil
	}
	var containsOnlyLetters: Bool {
		let notLetters = NSCharacterSet.letters.inverted
		return rangeOfCharacter(from: notLetters, options: String.CompareOptions.literal, range: nil) == nil
	}
	var isAlphanumeric: Bool {
		let notAlphanumeric = NSCharacterSet.decimalDigits.union(NSCharacterSet.letters).inverted
		return rangeOfCharacter(from: notAlphanumeric, options: String.CompareOptions.literal, range: nil) == nil
	}
	var isValidEmail: Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: self)
	}
	
	func replacingOccurrences(of search: String, with replacement: String, count maxReplacements: Int? = nil) -> String {
		var count = 0
		var returnValue = self
		while let range = returnValue.range(of: search) {
			returnValue = returnValue.replacingCharacters(in: range, with: replacement)
			count += 1
			
			// exit as soon as we've made all replacements
			if maxReplacements.exists {
				if count == maxReplacements { return returnValue }
			}
		}
		return returnValue
	}
	
	func truncate(to length: Int, addEllipsis: Bool = false, if conditional: @autoclosure ()->Bool = {true}()) -> String  {
		guard conditional() == true else { return self }
		
		if length > count { return self }

		let endPosition = self.index(self.startIndex, offsetBy: length)
		let trimmed = self[..<endPosition]

		if addEllipsis {
			return "\(trimmed)..."
		} else {
			return String(trimmed)
		}
	}
	
	func contains(_ c: Character) -> Bool {
		for i in 0..<self.count {
			if self[i] == c { return true }
		}
		return false
	}
	
	/// Add prefix only if the String currently does not have the specified prefix.
	func conditionallyAddPrefix(_ prefix: String) -> String {
		if self.hasPrefix(prefix) { return self }
		return "\(prefix)\(self)"
	}
	
	mutating func insert(separator: String, every n: Int) {
		self = inserting(separator: separator, every: n)
	}
	func inserting(separator: String, every n: Int) -> String {
		var result: String = ""
		let characters = Array(self)
		stride(from: 0, to: count, by: n).forEach {
			result += String(characters[$0..<min($0+n, count)])
			if $0+n < count {
				result += separator
			}
		}
		return result
	}
	
	func contains(substring: String) -> Bool {
		if firstRange(of: substring).exists {
			return true
		} else { return false }
	}
}

public extension StringProtocol {
	/// Returns `true` if any character in `characters` is non-empty and contained within `self` by
	/// case-sensitive, non-literal search. Otherwise, returns `false`.
	func containsAny<T>(of characters: T...) -> Bool where T : StringProtocol {
		for t in characters {
			if self.contains(t) { return true }
		}
		return false
	}
}

/// This extension adds subscript support to strings
public extension String {
	subscript (i: Int) -> Character {
		return self[index(startIndex, offsetBy: i)]
	}
	
	subscript (bounds: CountableRange<Int>) -> Substring {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		if end < start { return "" }
		return self[start..<end]
	}
	
	subscript (bounds: CountableClosedRange<Int>) -> Substring {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(startIndex, offsetBy: bounds.upperBound)
		if end < start { return "" }
		return self[start...end]
	}
	
	subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
		let start = index(startIndex, offsetBy: bounds.lowerBound)
		let end = index(endIndex, offsetBy: -1)
		if end < start { return "" }
		return self[start...end]
	}
	
	subscript (bounds: PartialRangeThrough<Int>) -> Substring {
		let end = index(startIndex, offsetBy: bounds.upperBound)
		if end < startIndex { return "" }
		return self[startIndex...end]
	}
	
	subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
		let end = index(startIndex, offsetBy: bounds.upperBound)
		if end < startIndex { return "" }
		return self[startIndex..<end]
	}
}
