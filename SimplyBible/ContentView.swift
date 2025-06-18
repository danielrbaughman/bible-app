import SwiftUI

struct Verse {
    var book: String
    var chapter: Int
    var verse: Int?
    
    func formatted() -> String {
        if verse == nil {
            return "\(book) \(chapter)"
        }
        
        return "\(book) \(chapter):\(verse!)"
    }
}

struct PassageView: View {
    var verseStart: Verse
    var verseEnd: Verse
    
    var body: some View {
        ScrollView {
            Text("""
                 Ut aute Lorem quis in dolore cillum proident. Lorem sit do incididunt tempor mollit. Tempor duis non labore cupidatat amet proident ut officia mollit eu veniam consectetur est Lorem ea. Nostrud laborum voluptate ea commodo commodo anim enim aliqua. Duis sit eiusmod mollit commodo ut.

                 Irure nostrud cupidatat est nostrud elit do minim ex qui consequat et laboris. Pariatur consectetur aute duis occaecat. Anim excepteur reprehenderit amet excepteur culpa aute tempor qui. Do ea sit ipsum ea. Consequat do in aliquip enim Lorem. Ipsum esse excepteur officia in deserunt cillum quis irure officia esse dolor magna anim aliqua aute. Aliqua veniam sit eiusmod veniam elit officia in duis.

                 Aute ut deserunt duis adipisicing aute mollit commodo veniam amet quis consequat do proident. Occaecat elit proident ad ipsum nostrud amet incididunt et commodo nulla occaecat in. Aliquip sit nisi laboris anim labore culpa culpa reprehenderit minim mollit pariatur sunt fugiat sint incididunt. Et nisi eiusmod deserunt eiusmod adipisicing incididunt consectetur. Eiusmod dolore sit fugiat nisi enim sint deserunt tempor Lorem eu. Cupidatat ullamco labore commodo eu esse ex consequat. Est officia aliquip enim consequat pariatur ut Lorem. Eu incididunt exercitation aliquip amet et.

                 Laboris pariatur enim Lorem. Aliquip magna tempor elit incididunt incididunt officia ipsum consectetur amet velit. Incididunt cillum non sit excepteur voluptate cillum. Sunt pariatur fugiat labore et adipisicing in non et dolor ut mollit id. Irure cupidatat ea consectetur dolore sit nulla Lorem officia irure sunt aliquip laboris dolor deserunt. Voluptate ad est nulla consectetur exercitation excepteur in ea elit amet mollit nostrud aute. Lorem aute adipisicing nulla excepteur non ullamco sint ut.

                 Qui aute duis culpa cillum ad mollit sit qui anim. Tempor sunt voluptate dolor enim est eiusmod aliquip velit. Tempor ipsum duis commodo ea reprehenderit. Laboris tempor esse magna magna dolore sint aliqua. Reprehenderit nulla sit adipisicing eu deserunt id aliqua officia ullamco enim dolore eu eu pariatur consequat. Voluptate eiusmod nisi incididunt do in in aliqua.
                """)
        }
    }
}

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
    var books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"]
    var passageEndSelectionOptions: [String] = ["Book", "Chapter", "Verse", "Range"]
    @State private var bookSelection: String = "Genesis"
    @State private var chapterSelection: Int = 1
    @State private var verseSelection: Int = 1
    @State private var chapterSelectionEnd: Int = 1
    @State private var verseSelectionEnd: Int = 1
    @State private var passageEndSelection = "Book"
    @State private var showPassageSelection = false
    @State private var showPassageStartSelection = false
    @State private var showPassageEndSelection = false
    @State private var showChapterSelection = false

    var chapters: Int {
        switch bookSelection {
            case "Genesis": 50;
            case "Exodus": 40;
            case "Leviticus": 27;
            case "Numbers": 36;
            case "Deuteronomy": 34;
            default: 0
        }
    }

    var verses = Int.random(in: 1...50)

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(books, id: \.self) {
                    NavigationLink("\($0)", value: $0)
                }
            }
            .navigationDestination(for: String.self) {_ in
                NavigationStack {
                    PassageView(verseStart: Verse(book: bookSelection, chapter: chapterSelection, verse: verseSelection), verseEnd: Verse(book: bookSelection, chapter: chapterSelection, verse: verseSelection))
                        .padding()
                        .sheet(isPresented: $showChapterSelection) {
                            ChapterPickerForm(chapters: chapters, chapterSelection: $chapterSelection)
                        }
                        .sheet(isPresented: $showPassageStartSelection) {
                            VersePickerForm(chapters: chapters, verses: verses, chapterSelection: $chapterSelection, verseSelection: $verseSelection)
                        }
                        .sheet(isPresented: $showPassageEndSelection) {
                            VersePickerForm(chapters: chapters, verses: verses, chapterSelection: $chapterSelectionEnd, verseSelection: $verseSelectionEnd)
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
                                    Button("\(Verse(book: bookSelection, chapter: chapterSelection).formatted())") {
                                        showChapterSelection.toggle()
                                    }
                                }

                                if (passageEndSelection == "Verse" || passageEndSelection == "Range") {
                                    Button("\(Verse(book: bookSelection, chapter: chapterSelection, verse: verseSelection).formatted())") {
                                        showPassageStartSelection.toggle()
                                    }
                                }

                                if (passageEndSelection == "Range") {
                                    Text("to")

                                    Button("\(Verse(book: bookSelection, chapter: chapterSelectionEnd, verse: verseSelectionEnd).formatted())") {
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
    }
}

#Preview {
    ContentView()
}
