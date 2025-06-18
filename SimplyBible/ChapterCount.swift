//
//  ChapterCount.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/18/25.
//

import Foundation

public struct ChapterCount: Codable {
    public var chapterCount: Int
    
    public init(chapterCount: Int) {
        self.chapterCount = chapterCount
    }
}
