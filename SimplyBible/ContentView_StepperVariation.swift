import SwiftUI

struct ContentView_StepperVariation: View {
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
                        VStack(spacing: 30) {
                            // Header with current selection
                            VStack {
                                Text("Current Selection")
                                    .font(.headline)
                                Text("\(bookSelection) \(chapterSelection):\(verseSelection)")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                            // Book Selection with Menu
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Book")
                                    .font(.headline)
                                
                                Menu {
                                    ForEach(books, id: \.self) { book in
                                        Button(book) {
                                            bookSelection = book
                                            chapterSelection = 1 // Reset chapter when book changes
                                            verseSelection = 1 // Reset verse when book changes
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(bookSelection)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Chapter Selection with Stepper and TextField
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Chapter")
                                    .font(.headline)
                                
                                HStack {
                                    TextField("Chapter", value: $chapterSelection, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .onChange(of: chapterSelection) { oldValue, newValue in
                                            if newValue < 1 {
                                                chapterSelection = 1
                                            } else if newValue > chapters {
                                                chapterSelection = chapters
                                            }
                                        }
                                    
                                    Stepper(value: $chapterSelection, in: 1...chapters) {
                                        Text("of \(chapters)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Chapter range indicator
                                HStack {
                                    Text("1")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    ProgressView(value: Double(chapterSelection), total: Double(chapters))
                                        .progressViewStyle(LinearProgressViewStyle())
                                    
                                    Text("\(chapters)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Verse Selection with Stepper and TextField
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Verse")
                                    .font(.headline)
                                
                                HStack {
                                    TextField("Verse", value: $verseSelection, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .onChange(of: verseSelection) { oldValue, newValue in
                                            if newValue < 1 {
                                                verseSelection = 1
                                            } else if newValue > verses {
                                                verseSelection = verses
                                            }
                                        }
                                    
                                    Stepper(value: $verseSelection, in: 1...verses) {
                                        Text("of \(verses)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Verse range indicator
                                HStack {
                                    Text("1")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    ProgressView(value: Double(verseSelection), total: Double(verses))
                                        .progressViewStyle(LinearProgressViewStyle())
                                    
                                    Text("\(verses)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Quick navigation buttons
                            VStack(spacing: 15) {
                                Text("Quick Navigation")
                                    .font(.headline)
                                
                                HStack(spacing: 20) {
                                    Button("First Verse") {
                                        verseSelection = 1
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button("Last Verse") {
                                        verseSelection = verses
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                HStack(spacing: 20) {
                                    Button("Previous Chapter") {
                                        if chapterSelection > 1 {
                                            chapterSelection -= 1
                                            verseSelection = 1
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(chapterSelection <= 1)
                                    
                                    Button("Next Chapter") {
                                        if chapterSelection < chapters {
                                            chapterSelection += 1
                                            verseSelection = 1
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(chapterSelection >= chapters)
                                }
                            }
                            .padding()
                            
                            Spacer()
                        }
                        .navigationTitle("Stepper Passage Selector")
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
    ContentView_StepperVariation()
}