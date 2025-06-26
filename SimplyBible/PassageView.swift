//
//  PassageView.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/25/25.
//

import SwiftUI

struct SwitchablePickerStyle: ViewModifier {
    var isSegmented: Bool
    func body(content: Content) -> some View {
        if isSegmented {
            content.pickerStyle(.segmented)
        } else {
            content.pickerStyle(.menu)
        }
    }
}

struct PassageModePicker: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var passageModes: [String]
    @Binding var passageMode: String

    var body: some View {
        Picker("Passage Mode", selection: $passageMode) {
            ForEach(passageModes, id: \.self) {
                Text("\($0)")
            }
        }
        .pickerStyle(.segmented)
//        .modifier(SwitchablePickerStyle(isSegmented: horizontalSizeClass == .regular))
    }
}

struct NumberPickerView: View {
    var label: String
    var range: Int
    @Binding var selection: Int

    var body: some View {
        Picker(selection: $selection, label: Text("\(label)")) {
            ForEach(1..<range+1, id: \.self) {
                Text("\($0)")
            }
        }
    }
}

struct ChapterPickerForm: View {
    var chapters: Int
    @Binding var chapter: Int

    var body: some View {
        VStack {
            Form {
                NumberPickerView(label: "Chapter", range: chapters, selection: $chapter)
            }
        }
    }
}

struct VersePickerForm: View {
    var chapters: Int
    var verses: Int
    @Binding var chapter: Int
    @Binding var verse: Int

    var body: some View {
        VStack {
            Form {
                NumberPickerView(label: "Chapter", range: chapters, selection: $chapter)
                
                NumberPickerView(label: "Verse", range: verses, selection: $verse)
            }
        }
    }
}

struct PassageIndex {
    var chapter: Int
    var verse: Int?
}

struct PassageView: View {
    var api: IQBibleAPI
    var book: Book

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Navigation Data
    @State private var chapters: Int = 0
    @State private var verses: Int = 0

    // Passage State
    @State private var passage: [VerseData] = []
    @State private var isLoadingPassage = false
    
    // Passage Selection UI
    var passageModes: [String] = ["Book", "Chapter", "Verse", "Range"]
    @State private var passageMode = "Chapter"
    @State private var showChooseChapterModal = false
    @State private var showChoosePassageStartModal = false
    @State private var showChoosePassageEndModal = false

    // Passage Selection State
    @State private var chapterStart: Int = 1
    @State private var chapterEnd: Int = 1
    @State private var verseStart: Int = 1
    @State private var verseEnd: Int = 1

    var verseMode: String {
        switch passageMode {
        case "Book":
            return "book"
        case "Chapter":
            return "chapter"
        case "Verse":
            return "verse"
        case "Range":
            return "verse"
        default:
            return "Invalid mode"
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isLoadingPassage {
                    VStack {
                        ProgressView()
                            .controlSize(.large)
                        
                        Text("Loading passage...")
                    }
                } else {
                    MultiVerseView(verses: passage)
                }
            }
            .task {
                await loadBookInfo(for: book)
                await loadPassage(book: book)
            }
            .sheet(isPresented: $showChooseChapterModal) {
                ChapterPickerForm(chapters: chapters, chapter: $chapterStart)
            }
            .sheet(isPresented: $showChoosePassageStartModal) {
                VersePickerForm(chapters: chapters, verses: verses, chapter: $chapterStart, verse: $verseStart)
            }
            .sheet(isPresented: $showChoosePassageEndModal) {
                VersePickerForm(chapters: chapters, verses: verses, chapter: $chapterEnd, verse: $verseEnd)
            }
            .onChange(of: book) { oldValue, newValue in
                Task {
                    await loadBookInfo(for: newValue)
                    await loadPassage(book: newValue)
                    // Reset verse selection to 1 when chapter changes
                    verseStart = 1
                }
            }
            .onChange(of: chapterStart) { oldValue, newValue in
                if chapterEnd < newValue {
                    chapterEnd = newValue
                }
                Task {
                    await loadVerseCount(for: book, chapter: newValue)
                    await loadPassage(book: book)
                    // Reset verse selection to 1 when chapter changes
                    verseStart = 1
                }
            }
            .onChange(of: chapterEnd) { oldValue, newValue in
                if newValue < chapterStart {
                    chapterEnd = chapterStart
                }
                Task {
                    await loadVerseCount(for: book, chapter: newValue)
                    await loadPassage(book: book)
                    // Reset verse selection to 1 when chapter changes
                    verseEnd = 1
                }
            }
            .onChange(of: verseStart) { oldValue, newValue in
                if verseEnd < newValue {
                    verseEnd = newValue
                }
                Task {
                    await loadPassage(book: book)
                }
            }
            .onChange(of: verseEnd) { oldValue, newValue in
                if newValue < verseStart {
                    verseEnd = verseStart
                }
                Task {
                    await loadPassage(book: book)
                }
            }
            .onChange(of: passageMode) { oldValue, newValue in
                Task {
                    await loadPassage(book: book)
                }
            }
            .toolbar {
                if horizontalSizeClass == .regular {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        PassageModePicker(passageModes: passageModes, passageMode: $passageMode)

                        if (passageMode == "Chapter") {
                            Button("\(Verse(book: book, chapter: chapterStart).formatted(mode: "chapter"))") {
                                showChooseChapterModal.toggle()
                            }
                        }

                        if (passageMode == "Verse" || passageMode == "Range") {
                            Button("\(Verse(book: book, chapter: chapterStart, verse: verseStart).formatted(mode: "verse"))") {
                                showChoosePassageStartModal.toggle()
                            }
                        }

                        if (passageMode == "Range") {
                            Text("to")

                            Button("\(Verse(book: book, chapter: chapterEnd, verse: verseEnd).formatted(mode: "verse"))") {
                                showChoosePassageEndModal.toggle()
                            }
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        PassageModePicker(passageModes: passageModes, passageMode: $passageMode)
                    }

                    ToolbarItemGroup(placement: .bottomBar) {
                        if passageMode == "Range" {
                            Spacer()
                            Spacer()
                        }

                        Button("\(Verse(book: book, chapter: chapterStart, verse: verseStart).formatted(mode: verseMode))") {
                            showChooseChapterModal.toggle()
                        }

                        if passageMode == "Range" {
                            Spacer()
                            Text("to")
                            Spacer()

                            Button("\(Verse(book: book, chapter: chapterEnd, verse: verseEnd).formatted(mode: verseMode))") {
                                showChoosePassageEndModal.toggle()
                            }

                            Spacer()
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    func getPassage(from book: Book, startAt indexStart: PassageIndex, endAt indexEnd: PassageIndex) async throws -> [VerseData] {
        var passage: [VerseData] = []

        if indexStart.chapter == indexEnd.chapter {
            // Single chapter range
            let chapterVerses = try await api.getChapter(
                bookId: book.id,
                chapter: indexStart.chapter
            )
            let filtered = chapterVerses.filter {
                if let verseNum = Int($0.verse) {
                    return verseNum >= indexStart.verse ?? 1 && verseNum <= indexEnd.verse ?? 1
                }
                return false
            }
            passage.append(contentsOf: filtered.compactMap { $0 })
        } else {
            // Multiple chapters
            // First chapter: from the first index to end
            let firstChapterVerses = try await api.getChapter(
                bookId: book.id,
                chapter: indexStart.chapter
            )
            let firstFiltered = firstChapterVerses.filter {
                if let verseNum = Int($0.verse) {
                    return verseNum >= indexStart.verse ?? 1
                }
                return false
            }
            passage.append(contentsOf: firstFiltered.compactMap { $0 })

            // Middle chapters: all verses
            if indexEnd.chapter > indexStart.chapter + 1 {
                for chapter in (indexStart.chapter + 1)..<indexEnd.chapter {
                    let middleChapterVerses = try await api.getChapter(
                        bookId: book.id,
                        chapter: chapter
                    )
                    passage.append(contentsOf: middleChapterVerses.compactMap { $0 })
                }
            }

            // Last chapter: from 1 to the end index
            let lastChapterVerses = try await api.getChapter(
                bookId: book.id,
                chapter: indexEnd.chapter
            )
            let lastFiltered = lastChapterVerses.filter {
                if let verseNum = Int($0.verse) {
                    return verseNum <= indexEnd.verse ?? 1
                }
                return false
            }
            passage.append(contentsOf: lastFiltered.compactMap { $0 })
        }

        return passage
    }

    func getPassage(from book: Book, chapter: Int) async throws -> [VerseData] {
        try await api.getChapter(bookId: book.id, chapter: chapter).compactMap { $0 }
    }

    func getPassage(from book: Book, index indexStart: PassageIndex) async throws -> [VerseData] {
        try await getPassage(from: book, startAt: indexStart, endAt: indexStart)
    }

    func getPassage(from book: Book) async throws -> [VerseData] {
        var passage: [VerseData] = []
        let chaptersCount = try await api.getChapterCount(bookId: book.id)
        for chapter in 1...chaptersCount {
            let verses = try await api.getChapter(bookId: book.id, chapter: chapter)
            passage.append(contentsOf: verses.compactMap { $0 })
        }
        return passage
    }

    func loadChapterCount(for book: Book) async {
        do {
            chapters = try await api.getChapterCount(bookId: book.id)
        } catch {
            fatalError()
        }
    }

    func loadVerseCount(for book: Book, chapter: Int) async {
        do {
            verses = try await api.getVerseCount(bookId: book.id, chapter: chapter)
        } catch {
            fatalError()
        }
    }

    func loadBookInfo(for book: Book) async {
        await loadChapterCount(for: book)
        await loadVerseCount(for: book, chapter: 1)
    }

    func loadPassage(book: Book) async {
        isLoadingPassage = true

        do {
            if passageMode == "Book" {
                passage = try await getPassage(from: book)
            } else if passageMode == "Chapter" {
                passage = try await getPassage(from: book, chapter: chapterStart)
            } else if passageMode == "Verse" {
                passage = try await getPassage(from: book, index: PassageIndex(chapter: chapterStart, verse: verseStart))
            } else if passageMode == "Range" {
                passage = try await getPassage(from: book, startAt: PassageIndex(chapter: chapterStart, verse: verseStart), endAt: PassageIndex(chapter: chapterEnd, verse: verseEnd))
            }
        } catch {
            fatalError()
        }

        isLoadingPassage = false
    }
}

#Preview {
    PassageView(api: IQBibleAPI(apiKey: "38fdb2453bmshba7572fc0922e6ap149b97jsnbc4ce6d440a3"), book: Book(id: "1", name: "Genesis"))
}
