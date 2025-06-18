//
//  Book.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/18/25.
//

import Foundation

public struct Book: Codable, Hashable {
    public enum CodingKeys: String, CodingKey {
        // Map the JSON key "url" to the Swift property name "htmlLink"
        case id = "b"
        case name = "n"
    }
    
    public var id: String
    public var name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
