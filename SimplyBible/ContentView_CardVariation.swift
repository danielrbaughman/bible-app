import SwiftUI

struct ContentView_CardVariation: View {
    var books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"]
    var passageEndSelectionOptions: [String] = ["Chapter", "Book", "Custom"]
    @State private var bookSelection: String = "Genesis"
    @State private var chapterSelection: Int = 1
    @State private var verseSelection: Int = 1
    @State private var passageEndSelection = "Chapter"
    @State private var showPassageSelection = false
    @State private var selectionStep = 1 // 1: Book, 2: Chapter, 3: Verse
    
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
                            // Progress indicator
                            HStack {
                                ForEach(1...3, id: \.self) { step in
                                    Circle()
                                        .fill(step <= selectionStep ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 12, height: 12)
                                    
                                    if step < 3 {
                                        Rectangle()
                                            .fill(step < selectionStep ? Color.blue : Color.gray.opacity(0.3))
                                            .frame(height: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            // Current selection summary
                            VStack {
                                Text("Current Selection")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(getCurrentSelectionText())
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            
                            // Card-based selection
                            ScrollView {
                                LazyVStack(spacing: 15) {
                                    if selectionStep == 1 {
                                        // Book selection cards
                                        ForEach(books, id: \.self) { book in
                                            BookCard(
                                                book: book,
                                                isSelected: book == bookSelection,
                                                chapters: getChaptersForBook(book)
                                            ) {
                                                bookSelection = book
                                                selectionStep = 2
                                            }
                                        }
                                        
                                    } else if selectionStep == 2 {
                                        // Chapter selection cards
                                        let chapterRows = Array(stride(from: 1, through: chapters, by: 5))
                                        
                                        ForEach(chapterRows, id: \.self) { startChapter in
                                            let endChapter = min(startChapter + 4, chapters)
                                            ChapterRowCard(
                                                startChapter: startChapter,
                                                endChapter: endChapter,
                                                selectedChapter: chapterSelection,
                                                bookName: bookSelection
                                            ) { chapter in
                                                chapterSelection = chapter
                                                selectionStep = 3
                                            }
                                        }
                                        
                                    } else if selectionStep == 3 {
                                        // Verse selection cards
                                        let verseRows = Array(stride(from: 1, through: verses, by: 10))
                                        
                                        ForEach(verseRows, id: \.self) { startVerse in
                                            let endVerse = min(startVerse + 9, verses)
                                            VerseRowCard(
                                                startVerse: startVerse,
                                                endVerse: endVerse,
                                                selectedVerse: verseSelection,
                                                reference: "\(bookSelection) \(chapterSelection)"
                                            ) { verse in
                                                verseSelection = verse
                                            }
                                        }
                                        
                                        // Complete selection button
                                        Button(action: {
                                            showPassageSelection = false
                                        }) {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                Text("Complete Selection")
                                                    .fontWeight(.semibold)
                                            }
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.green)
                                            .cornerRadius(12)
                                        }
                                        .padding(.top, 10)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer()
                        }
                        .navigationTitle("Card Passage Selector")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Back") {
                                    if selectionStep > 1 {
                                        selectionStep -= 1
                                    } else {
                                        showPassageSelection = false
                                    }
                                }
                            }
                            
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
                        selectionStep = 1 // Reset to first step
                    }) {
                        Text("Select Passage")
                    }
                }
            }
        }
    }
    
    private func getCurrentSelectionText() -> String {
        switch selectionStep {
        case 1:
            return "Select a Book"
        case 2:
            return "\(bookSelection) - Select Chapter"
        case 3:
            return "\(bookSelection) \(chapterSelection) - Select Verse"
        default:
            return "\(bookSelection) \(chapterSelection):\(verseSelection)"
        }
    }
    
    private func getChaptersForBook(_ book: String) -> Int {
        switch book {
            case "Genesis": 50
            case "Exodus": 40
            case "Leviticus": 27
            case "Numbers": 36
            case "Deuteronomy": 34
            default: 0
        }
    }
}

struct BookCard: View {
    let book: String
    let isSelected: Bool
    let chapters: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(book)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("\(chapters) chapters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundColor(isSelected ? .green : .secondary)
                    .font(.title3)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct ChapterRowCard: View {
    let startChapter: Int
    let endChapter: Int
    let selectedChapter: Int
    let bookName: String
    let action: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Chapters \(startChapter) - \(endChapter)")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                ForEach(startChapter...endChapter, id: \.self) { chapter in
                    Button(action: {
                        action(chapter)
                    }) {
                        Text("\(chapter)")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(selectedChapter == chapter ? .white : .primary)
                            .frame(width: 50, height: 50)
                            .background(selectedChapter == chapter ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct VerseRowCard: View {
    let startVerse: Int
    let endVerse: Int
    let selectedVerse: Int
    let reference: String
    let action: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Verses \(startVerse) - \(endVerse)")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                ForEach(startVerse...endVerse, id: \.self) { verse in
                    Button(action: {
                        action(verse)
                    }) {
                        Text("\(verse)")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(selectedVerse == verse ? .white : .primary)
                            .frame(width: 40, height: 40)
                            .background(selectedVerse == verse ? Color.blue : Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView_CardVariation()
}