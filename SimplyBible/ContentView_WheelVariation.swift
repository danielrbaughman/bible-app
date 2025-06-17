import SwiftUI

struct ContentView_WheelVariation: View {
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
                            // Current selection display
                            VStack {
                                Text("Selected Passage")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("\(bookSelection) \(chapterSelection):\(verseSelection)")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding()
                            
                            // Three-column wheel picker layout
                            HStack(spacing: 0) {
                                // Book Picker
                                VStack {
                                    Text("Book")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 5)
                                    
                                    Picker("Book", selection: $bookSelection) {
                                        ForEach(books, id: \.self) { book in
                                            Text(book)
                                                .font(.title3)
                                                .tag(book)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                    .clipped()
                                    .onChange(of: bookSelection) { oldValue, newValue in
                                        // Reset chapter and verse when book changes
                                        chapterSelection = 1
                                        verseSelection = 1
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider()
                                    .frame(height: 180)
                                
                                // Chapter Picker
                                VStack {
                                    Text("Chapter")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 5)
                                    
                                    Picker("Chapter", selection: $chapterSelection) {
                                        ForEach(1...chapters, id: \.self) { chapter in
                                            Text("\(chapter)")
                                                .font(.title3)
                                                .tag(chapter)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                    .clipped()
                                    .onChange(of: chapterSelection) { oldValue, newValue in
                                        // Reset verse when chapter changes
                                        verseSelection = 1
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider()
                                    .frame(height: 180)
                                
                                // Verse Picker
                                VStack {
                                    Text("Verse")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 5)
                                    
                                    Picker("Verse", selection: $verseSelection) {
                                        ForEach(1...verses, id: \.self) { verse in
                                            Text("\(verse)")
                                                .font(.title3)
                                                .tag(verse)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                    .clipped()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(15)
                            .padding(.horizontal)
                            
                            // Range indicators
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Chapter Range:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("1 - \(chapters)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                
                                HStack {
                                    Text("Verse Range:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("1 - \(verses)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 20)
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    showPassageSelection = false
                                }) {
                                    Text("Select This Passage")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                }
                                
                                HStack(spacing: 15) {
                                    Button("Reset to 1:1") {
                                        chapterSelection = 1
                                        verseSelection = 1
                                    }
                                    .buttonStyle(.bordered)
                                    
                                    Button("Random Verse") {
                                        chapterSelection = Int.random(in: 1...chapters)
                                        verseSelection = Int.random(in: 1...verses)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .navigationTitle("Wheel Passage Selector")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
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
    ContentView_WheelVariation()
}