import SwiftUI

struct ContentView: View {
    private let bible = IQBibleAPI(apiKey: "38fdb2453bmshba7572fc0922e6ap149b97jsnbc4ce6d440a3")

    @State private var books: [Book] = []
    @State private var isLoadingBooks = false

    var body: some View {
        NavigationSplitView {
            if isLoadingBooks {
                VStack {
                    ProgressView()
                        .controlSize(.large)

                    Text("Loading books...")
                }
            } else {
                List {
                    ForEach(books, id: \.id) { book in
                        NavigationLink("\(book.name)", value: book)
                    }
                }
                .navigationDestination(for: Book.self) { book in
                    PassageView(api: bible, book: book)
                }
            }
        } detail: {
            ContentUnavailableView("Select a book", systemImage: "book", description: Text("Our collection includes the whole Protestant canon."))
        }
        .task {
            isLoadingBooks = true
            await loadBooks()
            isLoadingBooks = false
        }
    }

    func loadBooks() async {
        do {
            books = try await bible.getBooks()
        } catch {
            fatalError("Failed to load books: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
