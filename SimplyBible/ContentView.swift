import SwiftUI

struct NumberPickerView: View {
    var label: String
    var range: Int
    @Binding var selection: Int

    var body: some View {
        Picker(selection: $selection, label: Text("\(label)")) {
            ForEach(0..<range+1, id: \.self) {
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
    @State private var passageEndSelection = "Book"
    @State private var showPassageSelection = false
    @State private var showPassageStartSelection = false
    @State private var showPassageEndSelection = false
    @State private var showChapterSelection = false

    @State private var chapters: Int = 0
    @State private var verses: Int = 0
    
    @State private var path = NavigationPath()

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(books, id: \.id) { book in
                    NavigationLink("\(book.name)", value: book)
                }
            }
            .navigationDestination(for: Book.self) { book in
                NavigationStack(path: $path) {
                    PassageView(verseStart: Verse(book: book, chapter: chapterSelection, verse: verseSelection), verseEnd: Verse(book: book, chapter: chapterSelection, verse: verseSelection))
                        .padding()
                        .sheet(isPresented: $showChapterSelection) {
                            ChapterPickerForm(chapters: 0, chapterSelection: $chapterSelection)
                        }
                        .sheet(isPresented: $showPassageStartSelection) {
                            VersePickerForm(chapters: chapters, verses: 1, chapterSelection: $chapterSelection, verseSelection: $verseSelection)
                        }
                        .sheet(isPresented: $showPassageEndSelection) {
                            VersePickerForm(chapters: chapters, verses: 1, chapterSelection: $chapterSelectionEnd, verseSelection: $verseSelectionEnd)
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
        } detail: {
            ContentUnavailableView("Select a book", systemImage: "book", description: Text("Our collection includes the whole Protestant canon."))
        }
        .task {
            await loadBooks()
        }
    }
    
    func loadBooks() async {
        let url = URL(string: "https://iq-bible.p.rapidapi.com/GetBooks?language=english")

        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("38fdb2453bmshba7572fc0922e6ap149b97jsnbc4ce6d440a3", forHTTPHeaderField: "x-rapidapi-key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let x = response as? HTTPURLResponse
                print(x?.statusCode ?? "No HTTP Response")
                if let resultBooks = try? JSONDecoder().decode([Book].self, from: data) {
                    books = resultBooks
                } else {
                    print("Invalid Response")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }

        task.resume()
    }
}

#Preview {
    ContentView()
}
