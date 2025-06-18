//
//  Verse.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/17/25.
//

import Foundation

public struct Verse {
    public var book: Book
    public var chapter: Int
    public var verse: Int?

    public init(book: Book, chapter: Int, verse: Int? = nil) {
        self.book = book
        self.chapter = chapter
        self.verse = verse
    }

    public func formatted() -> String {
        if verse == nil {
            return "\(book.name) \(chapter)"
        }

        return "\(book.name) \(chapter):\(verse!)"
    }
}
