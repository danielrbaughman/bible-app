# IQ Bible API Wrapper

A comprehensive Swift library for accessing the IQ Bible API, providing easy-to-use methods for retrieving Bible content.

## Features

- **Get Books**: Retrieve all available Bible books in a specified language
- **Chapter Count**: Get the number of chapters in any book
- **Verse Count**: Get the number of verses in any chapter
- **Passages**: Retrieve Bible text for specific verses, chapters, or ranges
- **Error Handling**: Comprehensive error handling with descriptive messages
- **Async/Await**: Modern Swift concurrency support
- **Cross-Platform**: Compatible with iOS, macOS, and Linux

## Usage

### Initialize the API

```swift
let api = IQBibleAPI(apiKey: "your-rapidapi-key-here")
```

### Get all books

```swift
do {
    let books = try await api.getBooks(language: "english")
    for book in books {
        print("\(book.name) (ID: \(book.id))")
    }
} catch {
    print("Error: \(error)")
}
```

### Get chapter count for a book

```swift
do {
    let chapterCount = try await api.getChapterCount(bookId: "1") // Genesis
    print("Genesis has \(chapterCount.chapterCount) chapters")
} catch {
    print("Error: \(error)")
}
```

### Get verse count for a chapter

```swift
do {
    let verseCount = try await api.getVerseCount(bookId: "1", chapter: 1)
    print("Genesis 1 has \(verseCount.verseCount) verses")
} catch {
    print("Error: \(error)")
}
```

### Get a Bible passage

```swift
// Get a single verse
do {
    let passage = try await api.getPassage(bookId: "1", chapter: 1, verse: 1)
    print(passage.text)
} catch {
    print("Error: \(error)")
}

// Get a whole chapter
do {
    let passage = try await api.getPassage(bookId: "1", chapter: 1)
    print(passage.text)
} catch {
    print("Error: \(error)")
}

// Get a range of verses
do {
    let passage = try await api.getPassage(
        bookId: "1", 
        chapter: 1, 
        verse: 1, 
        endChapter: 1, 
        endVerse: 5
    )
    print(passage.text)
} catch {
    print("Error: \(error)")
}
```

## Error Handling

The wrapper provides comprehensive error handling through the `APIError` enum:

- `invalidURL`: The constructed URL is invalid
- `invalidResponse`: The server response is invalid
- `httpError(Int)`: HTTP error with status code
- `decodingError`: Failed to decode the JSON response
- `networkError(Error)`: Network-related error

## Models

### Book
```swift
public struct Book: Codable, Hashable {
    public var id: String
    public var name: String
}
```

### ChapterCount
```swift
public struct ChapterCount: Codable {
    public var chapterCount: Int
}
```

### VerseCount
```swift
public struct VerseCount: Codable {
    public var verseCount: Int
}
```

### BiblePassage
```swift
public struct BiblePassage: Codable {
    public let text: String
    public let reference: String?
}
```

### Verse (Helper struct)
```swift
public struct Verse {
    public var book: Book
    public var chapter: Int
    public var verse: Int?
    
    public func formatted() -> String // Returns formatted reference like "Genesis 1:1"
}
```

## Requirements

- Swift 5.5+
- Foundation
- FoundationNetworking (on Linux)

## API Key

You need a RapidAPI key to access the IQ Bible API. Get one at [RapidAPI](https://rapidapi.com).