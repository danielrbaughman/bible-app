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

    func formatted(mode: String? = nil) -> String {
        switch mode {
        case "book":
            return book.name
        case "chapter":
            return "\(book.name) \(chapter)"
        case "verse":
            return "\(book.name) \(chapter):\(verse!)"
        default:
            break
        }

        return "No mode specified"
    }
}
