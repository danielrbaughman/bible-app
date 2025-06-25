//
//  MultiVerseWrapper.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/25/25.
//

import SwiftUI

struct MultiVerseView: View {
    var verses: [VerseData]
    var joinedVerses: String { verses.map(\.text).joined(separator: " ") }

    var body: some View {
        ScrollView {
            Text(joinedVerses)
        }
    }
}

#Preview {
    let passage = Bundle.main.decode([VerseData].self, from: "ExampleChapter.json")
    MultiVerseView(verses: passage)
}
