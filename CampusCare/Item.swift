//
//  Item.swift
//  CampusCare
//
//  Created by 汪一然 on 2026/7/14.
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
