//
//  Item.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 11/29/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
