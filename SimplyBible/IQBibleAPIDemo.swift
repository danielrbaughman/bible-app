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
        await demoSearch()
        await demoGetVersions()
        await demoGetRandomVerse()
        await demoGetCrossReferences()
        await demoGetBookInfo()
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
    
    private func demoSearch() async {
        print("\n🔍 Searching for 'love'...")
        do {
            let searchResults = try await api.search(query: "love", limit: 3)
            print("✅ Found \(searchResults.count) results:")
            for (index, result) in searchResults.enumerated() {
                print("  \(index + 1). \(result.reference): \"\(result.text.prefix(50))...\"")
            }
        } catch {
            print("❌ Failed to search: \(error)")
        }
    }
    
    private func demoGetVersions() async {
        print("\n📖 Getting available Bible versions...")
        do {
            let versions = try await api.getVersions()
            print("✅ Found \(versions.count) versions:")
            for (index, version) in versions.prefix(3).enumerated() {
                print("  \(index + 1). \(version.name) (\(version.abbreviation))")
            }
            if versions.count > 3 {
                print("  ... and \(versions.count - 3) more versions")
            }
        } catch {
            print("❌ Failed to get versions: \(error)")
        }
    }
    
    private func demoGetRandomVerse() async {
        print("\n🎲 Getting a random verse...")
        do {
            let randomVerse = try await api.getRandomVerse()
            print("✅ Random verse - \(randomVerse.reference):")
            print("   \"\(randomVerse.text)\"")
        } catch {
            print("❌ Failed to get random verse: \(error)")
        }
    }
    
    private func demoGetCrossReferences() async {
        print("\n🔗 Getting cross-references for John 3:16...")
        do {
            let crossRefs = try await api.getCrossReferences(bookId: "43", chapter: 3, verse: 16)
            print("✅ Found \(crossRefs.count) cross-references:")
            for (index, crossRef) in crossRefs.prefix(3).enumerated() {
                print("  \(index + 1). \(crossRef.toReference) (\(crossRef.relationType ?? "related"))")
            }
            if crossRefs.count > 3 {
                print("  ... and \(crossRefs.count - 3) more references")
            }
        } catch {
            print("❌ Failed to get cross-references: \(error)")
        }
    }
    
    private func demoGetBookInfo() async {
        print("\n📚 Getting detailed info for Genesis...")
        do {
            let bookInfo = try await api.getBookInfo(bookId: "1")
            print("✅ Book Info:")
            print("   Name: \(bookInfo.name)")
            print("   Testament: \(bookInfo.testament)")
            print("   Chapters: \(bookInfo.chapterCount)")
            if let author = bookInfo.author {
                print("   Author: \(author)")
            }
            if let summary = bookInfo.summary {
                print("   Summary: \(summary.prefix(100))...")
            }
        } catch {
            print("❌ Failed to get book info: \(error)")
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