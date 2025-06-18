//
//  Verse.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/17/25.
//

import Foundation

struct Verse {
    var book: String
    var chapter: Int
    var verse: Int?

    func formatted() -> String {
        if verse == nil {
            return "\(book) \(chapter)"
        }

        return "\(book) \(chapter):\(verse!)"
    }
}
