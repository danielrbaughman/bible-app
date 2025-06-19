import SwiftUI

struct ContentView_TabbedVariation: View {
    var books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"]
    var passageEndSelectionOptions: [String] = ["Chapter", "Book", "Custom"]
    @State private var bookSelection: String = "Genesis"
    @State private var chapterSelection: Int = 1
    @State private var verseSelection: Int = 1
    @State private var passageEndSelection = "Chapter"
    @State private var showPassageSelection = false
    @State private var selectedTab = 0
    
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
                        TabView(selection: $selectedTab) {
                            // Book Selection Tab
                            VStack {
                                Text("Select Book")
                                    .font(.title2)
                                    .padding()
                                
                                List {
                                    ForEach(books, id: \.self) { book in
                                        HStack {
                                            Text(book)
                                                .font(.headline)
                                            Spacer()
                                            if book == bookSelection {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            bookSelection = book
                                            selectedTab = 1 // Move to next tab
                                        }
                                    }
                                }
                            }
                            .tabItem {
                                Image(systemName: "book.closed")
                                Text("Book")
                            }
                            .tag(0)
                            
                            // Chapter Selection Tab
                            VStack {
                                Text("Select Chapter")
                                    .font(.title2)
                                    .padding()
                                
                                Text("Book: \(bookSelection)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                                    ForEach(1...chapters, id: \.self) { chapter in
                                        Button(action: {
                                            chapterSelection = chapter
                                            selectedTab = 2 // Move to next tab
                                        }) {
                                            Text("\(chapter)")
                                                .font(.title3)
                                                .padding()
                                                .frame(width: 50, height: 50)
                                                .background(chapterSelection == chapter ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(chapterSelection == chapter ? .white : .primary)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding()
                                
                                Spacer()
                            }
                            .tabItem {
                                Image(systemName: "list.number")
                                Text("Chapter")
                            }
                            .tag(1)
                            
                            // Verse Selection Tab
                            VStack {
                                Text("Select Verse")
                                    .font(.title2)
                                    .padding()
                                
                                Text("\(bookSelection) \(chapterSelection)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                    ForEach(1...verses, id: \.self) { verse in
                                        Button(action: {
                                            verseSelection = verse
                                        }) {
                                            Text("\(verse)")
                                                .font(.body)
                                                .padding(8)
                                                .frame(width: 40, height: 40)
                                                .background(verseSelection == verse ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(verseSelection == verse ? .white : .primary)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding()
                                
                                Spacer()
                                
                                Button("Complete Selection") {
                                    showPassageSelection = false
                                }
                                .buttonStyle(.borderedProminent)
                                .padding()
                            }
                            .tabItem {
                                Image(systemName: "textformat.123")
                                Text("Verse")
                            }
                            .tag(2)
                        }
                        .navigationTitle("Tabbed Passage Selector")
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
    ContentView_TabbedVariation()
}