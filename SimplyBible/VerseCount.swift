//
//  VerseCount.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/18/25.
//

import Foundation

public struct VerseCount: Codable {
    public var verseCount: Int
    
    public init(verseCount: Int) {
        self.verseCount = verseCount
    }
}
