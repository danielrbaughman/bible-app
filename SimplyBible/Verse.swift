//
//  Verse.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/17/25.
//

import Foundation

struct Verse {
    var book: Book
    var chapter: Int
    var verse: Int?

    func formatted() -> String {
        if verse == nil {
            return "\(book.name) \(chapter)"
        }

        return "\(book.name) \(chapter):\(verse!)"
    }
}
