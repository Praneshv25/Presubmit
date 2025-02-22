//
//  MistakeItem.swift
//  Presubmit
//
//  Created by Pranesh Velmurugan on 2/22/25.
//

import Foundation

struct MistakeItem: Codable, Identifiable {
    let id : UUID = UUID()
    let text: String
    let box_2d: [Int]
    let mistakes: String
}
