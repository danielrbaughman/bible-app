//
//  PassageView.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/17/25.
//

import SwiftUI

struct PassageView: View {
    var verseStart: Verse
    var verseEnd: Verse
    
    @State private var passageText: String = "Loading..."
    @State private var isLoading: Bool = true

    private let api = IQBibleAPI(apiKey: "38fdb2453bmshba7572fc0922e6ap149b97jsnbc4ce6d440a3")

    var body: some View {
        ScrollView {
            Text(passageText)
        }
        .task {
            await loadPassage()
        }
    }

    func loadPassage() async {
        do {
            // Handle cross-chapter ranges
            if verseStart.chapter != verseEnd.chapter {
                // Cross-chapter range - need to fetch multiple chapters
                var allVerses: [VerseData] = []
                
                for chapter in verseStart.chapter...verseEnd.chapter {
                    let chapterVerses = try await api.getChapter(
                        bookId: verseStart.book.id,
                        chapter: chapter
                    )
                    allVerses.append(contentsOf: chapterVerses)
                }
                
                let filteredVerses = allVerses.filter { verseData in
                    guard let chapterNum = Int(verseData.chapter),
                          let verseNum = Int(verseData.verse) else { return false }
                    
                    if chapterNum == verseStart.chapter {
                        // First chapter: include verses from start verse to end of chapter
                        return verseNum >= (verseStart.verse ?? 1)
                    } else if chapterNum == verseEnd.chapter {
                        // Last chapter: include verses from beginning to end verse
                        return verseNum <= (verseEnd.verse ?? verseNum)
                    } else {
                        // Middle chapters: include all verses
                        return true
                    }
                }
                
                let verseTexts = filteredVerses.map { verseData in
                    return "\(verseData.chapter):\(verseData.verse). \(verseData.text)"
                }
                
                passageText = verseTexts.joined(separator: "\n")
                
            } else {
                // Single chapter - original logic
                let allVerses = try await api.getChapter(
                    bookId: verseStart.book.id,
                    chapter: verseStart.chapter
                )
                
                let filteredVerses: [VerseData]
                
                // If specific verse(s) are selected, filter the chapter data
                if let startVerse = verseStart.verse {
                    let endVerse = verseEnd.verse ?? startVerse
                    filteredVerses = allVerses.filter { verseData in
                        if let verseNumber = Int(verseData.verse) {
                            return verseNumber >= startVerse && verseNumber <= endVerse
                        }
                        return false
                    }
                } else {
                    // No specific verse selected, show entire chapter
                    filteredVerses = allVerses
                }
                
                let verseTexts = filteredVerses.map { verseData in
                    // Include verse number in the output for individual verses
                    if verseStart.verse != nil {
                        return "\(verseData.verse). \(verseData.text)"
                    } else {
                        return verseData.text
                    }
                }
                
                passageText = verseTexts.joined(separator: "\n")
            }
        } catch {
            await MainActor.run {
                passageText = "Failed to load passage: \(error.localizedDescription)"
            }
        }
    }
}
