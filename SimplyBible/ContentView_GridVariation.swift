import SwiftUI

struct ContentView_GridVariation: View {
    var books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"]
    var passageEndSelectionOptions: [String] = ["Chapter", "Book", "Custom"]
    @State private var bookSelection: String = "Genesis"
    @State private var chapterSelection: Int = 1
    @State private var verseSelection: Int = 1
    @State private var passageEndSelection = "Chapter"
    @State private var showPassageSelection = false
    
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
            PassageView(verseStart: Verse(book: bookSelection, chapter: chapterSelection, verse: verseSelection), verseEnd: Verse(book: bookSelection, chapter: chapterSelection, verse: verseSelection))
                .padding()
                .sheet(isPresented: $showPassageSelection) {
                    NavigationView {
                        VStack(spacing: 20) {
                            // Book Selection
                            VStack(alignment: .leading) {
                                Text("Book")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                    ForEach(books, id: \.self) { book in
                                        Button(action: {
                                            bookSelection = book
                                        }) {
                                            Text(book)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(bookSelection == book ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(bookSelection == book ? .white : .primary)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            // Chapter Selection
                            VStack(alignment: .leading) {
                                Text("Chapter")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                                    ForEach(1...chapters, id: \.self) { chapter in
                                        Button(action: {
                                            chapterSelection = chapter
                                        }) {
                                            Text("\(chapter)")
                                                .padding(8)
                                                .frame(minWidth: 30)
                                                .background(chapterSelection == chapter ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(chapterSelection == chapter ? .white : .primary)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                            
                            // Verse Selection
                            VStack(alignment: .leading) {
                                Text("Verse")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 6) {
                                    ForEach(1...min(verses, 32), id: \.self) { verse in
                                        Button(action: {
                                            verseSelection = verse
                                        }) {
                                            Text("\(verse)")
                                                .padding(6)
                                                .frame(minWidth: 25)
                                                .background(verseSelection == verse ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(verseSelection == verse ? .white : .primary)
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .navigationTitle("Grid Passage Selector")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showPassageSelection = false
                                }
                            }
                        }
                    }
                }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showPassageSelection.toggle()
                    }) {
                        Text("Select Passage")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView_GridVariation()
}