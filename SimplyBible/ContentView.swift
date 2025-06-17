import SwiftUI

struct Verse {
    var book: String
    var chapter: Int
    var verse: Int
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

struct ContentView: View {
    var books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"]
    var passageEndSelectionOptions: [String] = ["Chapter", "Book", "Custom"]
    @State private var bookSelection: String = "Genesis"
    @State private var chapterSelection: Int = 1
    @State private var verseSelection: Int = 1
    @State private var passageEndSelection = "Chapter"
    
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
            
            VStack {
                Form {
                    Section("Start") {
                        Picker(selection: $chapterSelection, label: Text("Chapter")) {
                            ForEach(0..<chapters+1, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        
                        Picker(selection: $verseSelection, label: Text("Verse")) {
                            ForEach(0..<verses, id: \.self) {
                                Text("\($0)")
                            }
                        }
                    }
                    
                    Section("End") {
                        Picker("End of Passage", selection: $passageEndSelection) {
                            ForEach(passageEndSelectionOptions, id: \.self) {
                                Text("\($0)")
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        if passageEndSelection == "Custom" {
                            Picker(selection: $chapterSelection, label: Text("Chapter")) {
                                ForEach(0..<chapters+1, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                            
                            Picker(selection: $verseSelection, label: Text("Verse")) {
                                ForEach(0..<verses, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: 350)
        } detail: {
            PassageView(verseStart: Verse(book: bookSelection, chapter: chapterSelection, verse: verseSelection), verseEnd: Verse(book: bookSelection, chapter: chapterSelection, verse: verseSelection))
                    .padding()
        }
    }
}

#Preview {
    ContentView()
}
