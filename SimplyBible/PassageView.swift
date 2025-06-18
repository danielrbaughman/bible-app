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
            let verses = try await api.getChapter(
                bookId: verseStart.book.id,
                chapter: verseStart.chapter
            ).compactMap { $0.text as String }
            passageText = "\(verses.joined(separator: "\n"))"
        } catch {
            await MainActor.run {
                passageText = "Failed to load passage: \(error.localizedDescription)"
            }
        }
    }
}
