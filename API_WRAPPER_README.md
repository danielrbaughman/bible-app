# IQ Bible API Wrapper

A comprehensive Swift library for accessing the IQ Bible API, providing easy-to-use methods for retrieving Bible content, search functionality, audio resources, and study materials.

## Features

### Core Content
- **Get Books**: Retrieve all available Bible books in a specified language
- **Chapter Count**: Get the number of chapters in any book
- **Verse Count**: Get the number of verses in any chapter
- **Passages**: Retrieve Bible text for specific verses, chapters, or ranges

### Search & Discovery
- **Text Search**: Search for Bible text containing specific keywords
- **Reference Search**: Search by Bible reference patterns
- **Random Verse**: Get a random Bible verse with optional filters
- **Verse of the Day**: Retrieve the daily featured verse
- **Popular Verses**: Get frequently referenced verses

### Versions & Languages
- **Bible Versions**: Access different Bible translations
- **Language Support**: Multi-language Bible content
- **Version Comparison**: Support for different translations

### Study Resources
- **Cross-References**: Find related Bible passages
- **Commentary**: Access verse and chapter commentary
- **Topical Index**: Search by biblical topics and themes
- **Concordance**: Word study and occurrence tracking

### Metadata & Information
- **Book Information**: Detailed book metadata, authorship, and summaries
- **Chapter Information**: Chapter themes, summaries, and context
- **Study Notes**: Additional contextual information

### Audio Resources
- **Audio Verses**: Individual verse audio with multiple voices
- **Audio Chapters**: Full chapter audio with verse timestamps
- **Voice Options**: Multiple narrator choices

### Technical Features
- **Error Handling**: Comprehensive error handling with descriptive messages
- **Async/Await**: Modern Swift concurrency support
- **Cross-Platform**: Compatible with iOS, macOS, and Linux
- **Type Safety**: Strongly typed models and responses

## Usage

### Initialize the API

```swift
let api = IQBibleAPI(apiKey: "your-rapidapi-key-here")
```

### Core Content Methods

#### Get all books
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

#### Get chapter count for a book
```swift
do {
    let chapterCount = try await api.getChapterCount(bookId: "1") // Genesis
    print("Genesis has \(chapterCount.chapterCount) chapters")
} catch {
    print("Error: \(error)")
}
```

#### Get verse count for a chapter
```swift
do {
    let verseCount = try await api.getVerseCount(bookId: "1", chapter: 1)
    print("Genesis 1 has \(verseCount.verseCount) verses")
} catch {
    print("Error: \(error)")
}
```

#### Get a Bible passage
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

### Search Methods

#### Search by keyword
```swift
do {
    let results = try await api.search(query: "love", limit: 10)
    for result in results {
        print("\(result.reference): \(result.text)")
    }
} catch {
    print("Error: \(error)")
}
```

#### Search by reference
```swift
do {
    let passages = try await api.searchByReference(reference: "John 3:16")
    for passage in passages {
        print(passage.text)
    }
} catch {
    print("Error: \(error)")
}
```

### Discovery Methods

#### Get random verse
```swift
do {
    let randomVerse = try await api.getRandomVerse(testament: "new")
    print("\(randomVerse.reference): \(randomVerse.text)")
} catch {
    print("Error: \(error)")
}
```

#### Get verse of the day
```swift
do {
    let verseOfTheDay = try await api.getVerseOfTheDay()
    print("Today's verse: \(verseOfTheDay.reference)")
    print(verseOfTheDay.text)
    if let theme = verseOfTheDay.theme {
        print("Theme: \(theme)")
    }
} catch {
    print("Error: \(error)")
}
```

#### Get popular verses
```swift
do {
    let popularVerses = try await api.getPopularVerses(limit: 10)
    for verse in popularVerses {
        print("\(verse.reference): \(verse.text)")
    }
} catch {
    print("Error: \(error)")
}
```

### Version and Language Methods

#### Get available versions
```swift
do {
    let versions = try await api.getVersions()
    for version in versions {
        print("\(version.name) (\(version.abbreviation))")
    }
} catch {
    print("Error: \(error)")
}
```

#### Get available languages
```swift
do {
    let languages = try await api.getLanguages()
    for language in languages {
        print("\(language.name) (\(language.code))")
    }
} catch {
    print("Error: \(error)")
}
```

### Study Methods

#### Get cross-references
```swift
do {
    let crossRefs = try await api.getCrossReferences(bookId: "43", chapter: 3, verse: 16)
    for crossRef in crossRefs {
        print("See also: \(crossRef.toReference)")
    }
} catch {
    print("Error: \(error)")
}
```

#### Get commentary
```swift
do {
    let commentary = try await api.getCommentary(bookId: "1", chapter: 1, verse: 1)
    print("Commentary on Genesis 1:1:")
    print(commentary.content)
} catch {
    print("Error: \(error)")
}
```

#### Get topical index
```swift
do {
    let topicalEntries = try await api.getTopicalIndex(keyword: "faith")
    for entry in topicalEntries {
        print("\(entry.reference): \(entry.context ?? "")")
    }
} catch {
    print("Error: \(error)")
}
```

#### Get concordance
```swift
do {
    let concordanceEntries = try await api.getConcordance(word: "love", limit: 20)
    for entry in concordanceEntries {
        print("\(entry.reference): \(entry.context)")
    }
} catch {
    print("Error: \(error)")
}
```

### Metadata Methods

#### Get book information
```swift
do {
    let bookInfo = try await api.getBookInfo(bookId: "1")
    print("Book: \(bookInfo.name)")
    print("Testament: \(bookInfo.testament)")
    print("Chapters: \(bookInfo.chapterCount)")
    if let author = bookInfo.author {
        print("Author: \(author)")
    }
    if let summary = bookInfo.summary {
        print("Summary: \(summary)")
    }
} catch {
    print("Error: \(error)")
}
```

#### Get chapter information
```swift
do {
    let chapterInfo = try await api.getChapterInfo(bookId: "1", chapter: 1)
    print("Chapter: \(chapterInfo.chapter)")
    print("Verses: \(chapterInfo.verseCount)")
    if let title = chapterInfo.title {
        print("Title: \(title)")
    }
    if let summary = chapterInfo.summary {
        print("Summary: \(summary)")
    }
} catch {
    print("Error: \(error)")
}
```

### Audio Methods

#### Get audio verse
```swift
do {
    let audioVerse = try await api.getAudioVerse(bookId: "1", chapter: 1, verse: 1)
    print("Audio URL: \(audioVerse.audioUrl)")
    if let duration = audioVerse.duration {
        print("Duration: \(duration) seconds")
    }
} catch {
    print("Error: \(error)")
}
```

#### Get audio chapter
```swift
do {
    let audioChapter = try await api.getAudioChapter(bookId: "1", chapter: 1)
    print("Audio URL: \(audioChapter.audioUrl)")
    if let timestamps = audioChapter.verseTimestamps {
        for timestamp in timestamps.prefix(3) {
            print("Verse \(timestamp.verse): \(timestamp.startTime)s - \(timestamp.endTime)s")
        }
    }
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

### Core Models

#### Book
```swift
public struct Book: Codable, Hashable {
    public var id: String
    public var name: String
}
```

#### ChapterCount
```swift
public struct ChapterCount: Codable {
    public var chapterCount: Int
}
```

#### VerseCount
```swift
public struct VerseCount: Codable {
    public var verseCount: Int
}
```

#### BiblePassage
```swift
public struct BiblePassage: Codable {
    public let text: String
    public let reference: String?
}
```

### Search Models

#### SearchResult
```swift
public struct SearchResult: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
}
```

### Version Models

#### BibleVersion
```swift
public struct BibleVersion: Codable {
    public let id: String
    public let name: String
    public let abbreviation: String
    public let language: String
    public let description: String?
}
```

#### Language
```swift
public struct Language: Codable {
    public let code: String
    public let name: String
    public let nativeName: String?
}
```

### Discovery Models

#### RandomVerse
```swift
public struct RandomVerse: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
}
```

#### VerseOfTheDay
```swift
public struct VerseOfTheDay: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
    public let date: String
    public let theme: String?
}
```

#### PopularVerse
```swift
public struct PopularVerse: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
    public let popularity: Int?
}
```

### Study Models

#### CrossReference
```swift
public struct CrossReference: Codable {
    public let fromReference: String
    public let toBookId: String
    public let toBookName: String
    public let toChapter: Int
    public let toVerse: Int
    public let toReference: String
    public let relationType: String?
}
```

#### Commentary
```swift
public struct Commentary: Codable {
    public let reference: String
    public let title: String?
    public let content: String
    public let author: String?
    public let source: String?
    public let type: String?
}
```

#### TopicalEntry
```swift
public struct TopicalEntry: Codable {
    public let keyword: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let reference: String
    public let context: String?
}
```

#### ConcordanceEntry
```swift
public struct ConcordanceEntry: Codable {
    public let word: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let reference: String
    public let context: String
    public let occurrence: Int?
}
```

### Metadata Models

#### BookInfo
```swift
public struct BookInfo: Codable {
    public let id: String
    public let name: String
    public let fullName: String?
    public let testament: String
    public let chapterCount: Int
    public let author: String?
    public let writtenDate: String?
    public let summary: String?
    public let genre: String?
}
```

#### ChapterInfo
```swift
public struct ChapterInfo: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verseCount: Int
    public let title: String?
    public let summary: String?
    public let theme: String?
}
```

### Audio Models

#### AudioVerse
```swift
public struct AudioVerse: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let reference: String
    public let audioUrl: String
    public let duration: Double?
    public let voice: String?
}
```

#### AudioChapter
```swift
public struct AudioChapter: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let audioUrl: String
    public let duration: Double?
    public let voice: String?
    public let verseTimestamps: [VerseTimestamp]?
}
```

#### VerseTimestamp
```swift
public struct VerseTimestamp: Codable {
    public let verse: Int
    public let startTime: Double
    public let endTime: Double
}
```

### Helper Models

#### Verse (Helper struct)
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