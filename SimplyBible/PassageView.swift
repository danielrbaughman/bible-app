//
//  PassageView.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/25/25.
//

import SwiftUI

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
    @Binding var chapterSelection: Int

    var body: some View {
        VStack {
            Form {
                NumberPickerView(label: "Chapter", range: chapters, selection: $chapterSelection)
            }
        }
    }
}

struct VersePickerForm: View {
    var chapters: Int
    var verses: Int
    @Binding var chapterSelection: Int
    @Binding var verseSelection: Int

    var body: some View {
        VStack {
            Form {
                NumberPickerView(label: "Chapter", range: chapters, selection: $chapterSelection)
                
                NumberPickerView(label: "Verse", range: verses, selection: $verseSelection)
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
    
    @State private var passage: [VerseData] = []
    @State private var passageStart: PassageIndex = PassageIndex(chapter: 1, verse: 1)
    @State private var passageEnd: PassageIndex = PassageIndex(chapter: 1, verse: 1)
    @State private var isLoadingPassage = false
    var passageEndSelectionOptions: [String] = ["Book", "Chapter", "Verse", "Range"]
    @State private var chapterSelection: Int = 1
    @State private var verseSelection: Int = 1
    @State private var chapterSelectionEnd: Int = 1
    @State private var verseSelectionEnd: Int = 1
    @State private var passageEndSelection = "Chapter"
    @State private var showPassageSelection = false
    @State private var showPassageStartSelection = false
    @State private var showPassageEndSelection = false
    @State private var showChapterSelection = false
    @State private var chapters: Int = 0
    @State private var verses: Int = 0
    @State private var path = NavigationPath()
    
    var passageText: String { passage.map(\.text).joined(separator: " ") }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if isLoadingPassage {
                    VStack {
                        ProgressView()
                            .controlSize(.large)
                        
                        Text("Loading passage...")
                    }
                } else {
                    ScrollView {
                        Text(passageText)
                    }
                }
            }
            .task {
                await loadPassage(book: book)
            }
            .sheet(isPresented: $showChapterSelection) {
                ChapterPickerForm(chapters: chapters, chapterSelection: $chapterSelection)
            }
            .sheet(isPresented: $showPassageStartSelection) {
                VersePickerForm(chapters: chapters, verses: verses, chapterSelection: $chapterSelection, verseSelection: $verseSelection)
            }
            .sheet(isPresented: $showPassageEndSelection) {
                VersePickerForm(chapters: chapters, verses: verses, chapterSelection: $chapterSelectionEnd, verseSelection: $verseSelectionEnd)
            }
            .task {
                await loadBookInfo(for: book)
            }
            .onChange(of: book) { oldValue, newValue in
                Task {
                    await loadBookInfo(for: newValue)
                    await loadPassage(book: newValue)
                    // Reset verse selection to 1 when chapter changes
                    verseSelection = 1
                }
            }
            .onChange(of: chapterSelection) { oldValue, newValue in
                if chapterSelectionEnd < newValue {
                    chapterSelectionEnd = newValue
                    passageEnd.chapter = newValue
                }
                Task {
                    await loadVerseCount(for: book, chapter: newValue)
                    await loadPassage(book: book)
                    // Reset verse selection to 1 when chapter changes
                    verseSelection = 1
                    passageStart.verse = 1
                }
            }
            .onChange(of: chapterSelectionEnd) { oldValue, newValue in
                if newValue < chapterSelection {
                    chapterSelectionEnd = chapterSelection
                    passageEnd.chapter = chapterSelection
                }
                Task {
                    await loadVerseCount(for: book, chapter: newValue)
                    await loadPassage(book: book)
                    // Reset verse selection to 1 when chapter changes
                    verseSelectionEnd = 1
                    passageEnd.verse = 1
                }
            }
            .onChange(of: verseSelection) { oldValue, newValue in
                if verseSelectionEnd < newValue {
                    verseSelectionEnd = newValue
                    passageEnd.verse = newValue
                }
                Task {
                    await loadPassage(book: book)
                }
            }
            .onChange(of: verseSelectionEnd) { oldValue, newValue in
                if newValue < verseSelection {
                    verseSelectionEnd = verseSelection
                    passageEnd.verse = verseSelection
                }
                Task {
                    await loadPassage(book: book)
                }
            }
            .onChange(of: passageEndSelection) { oldValue, newValue in
                Task {
                    await loadPassage(book: book)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Picker("Passage Setting", selection: $passageEndSelection) {
                        ForEach(passageEndSelectionOptions, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if (passageEndSelection == "Chapter") {
                        Button("\(Verse(book: book, chapter: chapterSelection).formatted())") {
                            showChapterSelection.toggle()
                        }
                    }
                    
                    if (passageEndSelection == "Verse" || passageEndSelection == "Range") {
                        Button("\(Verse(book: book, chapter: chapterSelection, verse: verseSelection).formatted())") {
                            showPassageStartSelection.toggle()
                        }
                    }
                    
                    if (passageEndSelection == "Range") {
                        Text("to")
                        
                        Button("\(Verse(book: book, chapter: chapterSelectionEnd, verse: verseSelectionEnd).formatted())") {
                            showPassageEndSelection.toggle()
                        }
                    }
                }
            }
        }
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
            verses = try await api.getVerseCount(bookId: book.id, chapter: chapterSelection)
        } catch {
            fatalError()
        }
    }

    func loadBookInfo(for book: Book) async {
        await loadChapterCount(for: book)
        await loadVerseCount(for: book, chapter: 1)
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
    
    func getPassage(from book: Book, chapter: Int) async throws -> [VerseData] {
        try await api.getChapter(bookId: book.id, chapter: chapterSelection).compactMap { $0 }
    }

    func getPassage(from book: Book, index indexStart: PassageIndex) async throws -> [VerseData] {
        try await getPassage(from: book, startAt: indexStart, endAt: indexStart)
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
            // First chapter: from verseSelection to end
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

            // Last chapter: from 1 to verseSelectionEnd
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

    func loadPassage(book: Book) async {
        isLoadingPassage = true

        do {
            if passageEndSelection == "Book" {
                passage = try await getPassage(from: book)
            } else if passageEndSelection == "Chapter" {
                passage = try await getPassage(from: book, chapter: passageStart.chapter)
            } else if passageEndSelection == "Verse" {
                passage = try await getPassage(from: book, index: passageStart)
            } else if passageEndSelection == "Range" {
                passage = try await getPassage(from: book, startAt: passageStart, endAt: passageEnd)
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
