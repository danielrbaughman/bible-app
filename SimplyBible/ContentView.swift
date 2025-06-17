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
        VStack {
            Text("In the beginning, God created the heavens and the earth.")
            
            Spacer()
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
                    Text("\($0)")
                }
            }
        } detail: {
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
    }
}

#Preview {
    ContentView()
}
