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
    @State private var isLoading: Bool = true

    @State private var chapters: Int = 0
    @State private var verses: Int = 0
    
    @State private var path = NavigationPath()
    
    private let api = IQBibleAPI(apiKey: "38fdb2453bmshba7572fc0922e6ap149b97jsnbc4ce6d440a3")

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(books, id: \.id) { book in
                    NavigationLink("\(book.name)", value: book)
                }
            }
            .navigationDestination(for: Book.self) { book in
                NavigationStack(path: $path) {
                    ScrollView {
                        Text(passageText)
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
                        Task {
                            await loadVerseCount(for: book, chapter: newValue)
                            await loadPassage(book: book)
                            // Reset verse selection to 1 when chapter changes
                            verseSelection = 1
                        }
                    }
                    .onChange(of: chapterSelectionEnd) { oldValue, newValue in
                        Task {
                            await loadVerseCount(for: book, chapter: newValue)
                            await loadPassage(book: book)
                            // Reset verse selection to 1 when chapter changes
                            verseSelectionEnd = 1
                        }
                    }
                    .onChange(of: passageEndSelection) { oldValue, newValue in
                        Task {
                            await loadPassage(book: book)
                            // Reset verse selection to 1 when chapter changes
                            verseSelectionEnd = 1
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

<<<<<<< HEAD
                                if (passageEndSelection == "Book") {
                                    Button("\(book.name)") {
                                        // No additional selection needed for book
                                    }
                                }

                                if (passageEndSelection == "Chapter") {
                                    Button("\(Verse(book: book, chapter: chapterSelection).formatted())") {
                                        showChapterSelection.toggle()
                                    }
                                }
=======
                            if (passageEndSelection == "Range") {
                                Text("to")
>>>>>>> fde863c08ff7a61f070e02504464e1b083747216

                                Button("\(Verse(book: book, chapter: chapterSelectionEnd, verse: verseSelectionEnd).formatted())") {
                                    showPassageEndSelection.toggle()
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
        do {
            books = try await api.getBooks()
        } catch {
            fatalError("Failed to load books: \(error)")
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
            verses = try await api.getVerseCount(bookId: book.id, chapter: chapter)
        } catch {
            fatalError()
        }
    }
    
    func loadBookInfo(for book: Book) async {
        await loadChapterCount(for: book)
        await loadVerseCount(for: book, chapter: chapterSelection)
    }
    
    func loadPassage(book: Book) async {
        if passageEndSelection == "Chapter" {
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
        } else if passageEndSelection == "Book" {
            print("B")
        } else if passageEndSelection == "Verse" {
            print("Verse")
            do {
                let verse = try await api.getVerse(verse: verseSelection)
                passageText = verse.text
            } catch {
                await MainActor.run {
                    passageText = "Failed to load passage: \(error.localizedDescription)"
                }
            }
        } else if passageEndSelection == "Range" {
            print("R")
        }
    }
}

#Preview {
    ContentView()
}
