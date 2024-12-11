//
//  SSectionData.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 11/29/24.
//

import Foundation
import SwiftData

@Model
final class SSectionData {	
	@Attribute(.unique) var dateCreated: Date
	var timestamp: Date
	var name: String
	var section: SSectionCFS

	init(dateCreated: Date? = nil, timestamp: Date, name: String, section: SSectionCFS) {
		self.dateCreated = dateCreated ?? timestamp
		self.name = name
		self.timestamp = timestamp
		self.section = section
    }
}

