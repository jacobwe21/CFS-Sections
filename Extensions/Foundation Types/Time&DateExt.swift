import Foundation
import CoreText

public extension Date {
	
	func days(between otherDate: Date) -> Int {
		let calendar = Calendar.current

		let startOfSelf = calendar.startOfDay(for: self)
		let startOfOther = calendar.startOfDay(for: otherDate)
		let components = calendar.dateComponents([.day], from: startOfSelf, to: startOfOther)

		return abs(components.day ?? 0)
	}
	
	static func - (firstDate: Self, laterDate: Self) -> TimeInterval {
		return laterDate.timeIntervalSince(firstDate)
	}
}

public extension Duration {
	static func minutes<T>(_ minutes: T) -> Duration where T : BinaryInteger {
		.seconds(minutes*60)
	}
	static func minutes(_ minutes: Double) -> Duration {
		.seconds(minutes*60)
	}
	static func hours<T>(_ hours: T) -> Duration where T : BinaryInteger {
		.seconds(hours*3600)
	}
	static func hours(_ hours: Double) -> Duration {
		.seconds(hours*3600)
	}
	static func days<T>(_ days: T) -> Duration where T : BinaryInteger {
		.seconds(days*86400)
	}
	static func days(_ days: Double) -> Duration {
		.seconds(days*86400)
	}
}
