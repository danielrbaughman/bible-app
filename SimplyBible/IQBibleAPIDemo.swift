//
//  IQBibleAPIDemo.swift
//  SimplyBible
//
//  Created by AI Assistant on 12/21/24.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Demo showing how to use the IQ Bible API wrapper
/// This file demonstrates the API wrapper in a console application context
class IQBibleAPIDemo {
    
    private let api: IQBibleAPI
    
    init(apiKey: String) {
        self.api = IQBibleAPI(apiKey: apiKey)
    }
    
    /// Run the demo
    func runDemo() async {
        print("🔥 IQ Bible API Wrapper Demo")
        print("=" * 40)
        
        await demoGetBooks()
        await demoGetChapterCount()
        await demoGetVerseCount()
        await demoGetPassage()
    }
    
    private func demoGetBooks() async {
        print("\n📚 Getting all books...")
        do {
            let books = try await api.getBooks()
            print("✅ Successfully loaded \(books.count) books:")
            for (index, book) in books.prefix(5).enumerated() {
                print("  \(index + 1). \(book.name) (ID: \(book.id))")
            }
            if books.count > 5 {
                print("  ... and \(books.count - 5) more books")
            }
        } catch {
            print("❌ Failed to load books: \(error)")
        }
    }
    
    private func demoGetChapterCount() async {
        print("\n📖 Getting chapter count for Genesis...")
        do {
            let chapterCount = try await api.getChapterCount(bookId: "1")
            print("✅ Genesis has \(chapterCount.chapterCount) chapters")
        } catch {
            print("❌ Failed to get chapter count: \(error)")
        }
    }
    
    private func demoGetVerseCount() async {
        print("\n🔢 Getting verse count for Genesis 1...")
        do {
            let verseCount = try await api.getVerseCount(bookId: "1", chapter: 1)
            print("✅ Genesis 1 has \(verseCount.verseCount) verses")
        } catch {
            print("❌ Failed to get verse count: \(error)")
        }
    }
    
    private func demoGetPassage() async {
        print("\n📝 Getting Genesis 1:1...")
        do {
            let passage = try await api.getPassage(bookId: "1", chapter: 1, verse: 1)
            print("✅ Genesis 1:1:")
            print("   \"\(passage.text)\"")
        } catch {
            print("❌ Failed to get passage: \(error)")
        }
    }
}

// Helper extension for string repetition
extension String {
    static func * (string: String, count: Int) -> String {
        return String(repeating: string, count: count)
    }
}

// Uncomment to run the demo (when you have a valid API key):
// 
// Task {
//     let demo = IQBibleAPIDemo(apiKey: "your-rapidapi-key-here")
//     await demo.runDemo()
// }