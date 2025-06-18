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
            if isLoading {
                ProgressView("Loading passage...")
                    .padding()
            } else {
                Text(passageText)
                    .padding()
            }
        }
        .task {
            await loadPassage()
        }
    }
    
    private func loadPassage() async {
        do {
            let passage = try await api.getPassage(
                bookId: verseStart.book.id,
                chapter: verseStart.chapter,
                verse: verseStart.verse,
                endChapter: verseEnd.chapter != verseStart.chapter ? verseEnd.chapter : nil,
                endVerse: verseEnd.verse != verseStart.verse ? verseEnd.verse : nil
            )
            await MainActor.run {
                passageText = passage.text
                isLoading = false
            }
        } catch {
            await MainActor.run {
                passageText = "Failed to load passage: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

//#Preview {
//    let genesis = Book(id: "1", name: "Genesis")
//    PassageView(verseStart: Verse(book: genesis, chapter: 1, verse: 1), verseEnd: Verse(book: genesis, chapter: 1, verse: 1))
//}
