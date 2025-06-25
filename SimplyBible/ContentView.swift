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

struct ContentView: View {
    @State private var books: [Book] = []
    var passageEndSelectionOptions: [String] = ["Book", "Chapter", "Verse", "Range"]
    @State private var chapterSelection: Int = 1
    @State private var bookSelection: Book? = nil
    @State private var verseSelection: Int = 1
    @State private var chapterSelectionEnd: Int = 1
    @State private var verseSelectionEnd: Int = 1
    @State private var passageEndSelection = "Chapter"
    @State private var showPassageSelection = false
    @State private var showPassageStartSelection = false
    @State private var showPassageEndSelection = false
    @State private var showChapterSelection = false
    
    @State private var passageText: String = "Loading..."
    @State private var isLoadingPassage = false
    @State private var isLoadingBooks = false
    @State private var isLoading: Bool = true

    @State private var chapters: Int = 0
    @State private var verses: Int = 0
    
    @State private var path = NavigationPath()
    
    private let api = IQBibleAPI(apiKey: "38fdb2453bmshba7572fc0922e6ap149b97jsnbc4ce6d440a3")

    var body: some View {
        NavigationSplitView {
            if isLoadingBooks {
                VStack {
                    ProgressView()
                        .controlSize(.large)

                    Text("Loading books...")
                }
            } else {
                List {
                    ForEach(books, id: \.id) { book in
                        NavigationLink("\(book.name)", value: book)
                    }
                }
                .navigationDestination(for: Book.self) { book in
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
                            }
                            Task {
                                await loadVerseCount(for: book, chapter: newValue)
                                await loadPassage(book: book)
                                // Reset verse selection to 1 when chapter changes
                                verseSelection = 1
                            }
                        }
                        .onChange(of: chapterSelectionEnd) { oldValue, newValue in
                            if newValue < chapterSelection {
                                chapterSelectionEnd = chapterSelection
                            }
                            Task {
                                await loadVerseCount(for: book, chapter: newValue)
                                await loadPassage(book: book)
                                // Reset verse selection to 1 when chapter changes
                                verseSelectionEnd = 1
                            }
                        }
                        .onChange(of: verseSelection) { oldValue, newValue in
                            if verseSelectionEnd < newValue {
                                verseSelectionEnd = newValue
                            }
                            Task {
                                await loadPassage(book: book)
                            }
                        }
                        .onChange(of: verseSelectionEnd) { oldValue, newValue in
                            if newValue < verseSelection {
                                verseSelectionEnd = verseSelection
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
            }
        } detail: {
            ContentUnavailableView("Select a book", systemImage: "book", description: Text("Our collection includes the whole Protestant canon."))
        }
        .task {
            await loadBooks()
        }
    }
    
    func loadBooks() async {
        isLoadingBooks = true
        do {
            books = try await api.getBooks()
        } catch {
            fatalError("Failed to load books: \(error)")
        }
        isLoadingBooks = false
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
        await loadVerseCount(for: book, chapter: chapterSelection)
    }
    
    func loadPassage(book: Book) async {
        isLoadingPassage = true

        if passageEndSelection == "Book" {
            do {
                let chaptersCount = try await api.getChapterCount(bookId: book.id)
                var allVerses: [String] = []
                for chapter in 1...chaptersCount {
                    let verses = try await api.getChapter(bookId: book.id, chapter: chapter)
                    allVerses.append(contentsOf: verses.compactMap { $0.text as String })
                }
                passageText = allVerses.joined(separator: "\n")
            } catch {
                await MainActor.run {
                    passageText = "Failed to load book: \(error.localizedDescription)"
                }
            }
        } else if passageEndSelection == "Chapter" {
            do {
                let verses = try await api.getChapter(
                    bookId: book.id,
                    chapter: chapterSelection
                ).compactMap { $0.text as String }
                passageText = "\(verses.joined(separator: "\n"))"
            } catch {
                await MainActor.run {
                    passageText = "Failed to load passage: \(error.localizedDescription)"
                }
            }
        } else if passageEndSelection == "Verse" {
            do {
                let chapterVerses = try await api.getChapter(
                    bookId: book.id,
                    chapter: chapterSelection
                )
                if let verseData = chapterVerses.first(where: { Int($0.verse) == verseSelection }) {
                    passageText = verseData.text
                } else {
                    passageText = "Verse not found."
                }
            } catch {
                await MainActor.run {
                    passageText = "Failed to load verse: \(error.localizedDescription)"
                }
            }
        } else if passageEndSelection == "Range" {
            do {
                var versesInRange: [String] = []
                if chapterSelection == chapterSelectionEnd {
                    // Single chapter range
                    let chapterVerses = try await api.getChapter(
                        bookId: book.id,
                        chapter: chapterSelection
                    )
                    let filtered = chapterVerses.filter {
                        if let verseNum = Int($0.verse) {
                            return verseNum >= verseSelection && verseNum <= verseSelectionEnd
                        }
                        return false
                    }
                    versesInRange.append(contentsOf: filtered.compactMap { $0.text })
                } else {
                    // Multiple chapters
                    // First chapter: from verseSelection to end
                    let firstChapterVerses = try await api.getChapter(
                        bookId: book.id,
                        chapter: chapterSelection
                    )
                    let firstFiltered = firstChapterVerses.filter {
                        if let verseNum = Int($0.verse) {
                            return verseNum >= verseSelection
                        }
                        return false
                    }
                    versesInRange.append(contentsOf: firstFiltered.compactMap { $0.text })

                    // Middle chapters: all verses
                    if chapterSelectionEnd > chapterSelection + 1 {
                        for chapter in (chapterSelection + 1)..<chapterSelectionEnd {
                            let middleChapterVerses = try await api.getChapter(
                                bookId: book.id,
                                chapter: chapter
                            )
                            versesInRange.append(contentsOf: middleChapterVerses.compactMap { $0.text })
                        }
                    }

                    // Last chapter: from 1 to verseSelectionEnd
                    let lastChapterVerses = try await api.getChapter(
                        bookId: book.id,
                        chapter: chapterSelectionEnd
                    )
                    let lastFiltered = lastChapterVerses.filter {
                        if let verseNum = Int($0.verse) {
                            return verseNum <= verseSelectionEnd
                        }
                        return false
                    }
                    versesInRange.append(contentsOf: lastFiltered.compactMap { $0.text })
                }
                passageText = versesInRange.joined(separator: "\n")
            } catch {
                await MainActor.run {
                    passageText = "Failed to load range: \(error.localizedDescription)"
                }
            }
        }

        isLoadingPassage = false
    }
}

#Preview {
    ContentView()
}
