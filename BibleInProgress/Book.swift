//
//  Book.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/18/25.
//

import Foundation

struct Book: Codable, Hashable {
    enum CodingKeys: String, CodingKey {
        // Map the JSON key "url" to the Swift property name "htmlLink"
        case id = "b"
        case name = "n"
    }
    
    var id: String
    var name: String
}
