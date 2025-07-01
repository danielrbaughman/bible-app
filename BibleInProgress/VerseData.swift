//
//  VerseData.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/18/25.
//

import Foundation

struct VerseData: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case book = "b"
        case chapter = "c"
        case verse = "v"
        case text = "t"
    }
    
    var id: String
    var book: String
    var chapter: String
    var verse: String
    var text: String
}
