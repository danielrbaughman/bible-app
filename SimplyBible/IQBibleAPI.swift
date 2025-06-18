//
//  IQBibleAPI.swift
//  SimplyBible
//
//  Created by AI Assistant on 12/21/24.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A comprehensive wrapper for the IQ Bible API
public class IQBibleAPI {
    
    // MARK: - Properties
    
    private let baseURL = "https://iq-bible.p.rapidapi.com"
    private let apiKey: String
    private let session: URLSession
    
    // MARK: - Initialization
    
    /// Initialize the IQ Bible API with an API key
    /// - Parameter apiKey: Your RapidAPI key for IQ Bible API
    public init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    // MARK: - API Methods
    
    /// Fetch all available books in the specified language
    /// - Parameter language: The language to fetch books in (default: "english")
    /// - Returns: An array of Book objects
    /// - Throws: APIError if the request fails
    public func getBooks(language: String = "english") async throws -> [Book] {
        let endpoint = "/GetBooks"
        let queryItems = [URLQueryItem(name: "language", value: language)]
        
        let books: [Book] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return books
    }
    
    /// Get the number of chapters in a specific book
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - language: The language (default: "english")
    /// - Returns: ChapterCount object containing the number of chapters
    /// - Throws: APIError if the request fails
    public func getChapterCount(bookId: String, language: String = "english") async throws -> ChapterCount {
        let endpoint = "/GetChapterCount"
        let queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "language", value: language)
        ]
        
        let chapterCount: ChapterCount = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return chapterCount
    }
    
    /// Get the number of verses in a specific chapter
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - chapter: The chapter number
    ///   - language: The language (default: "english")
    /// - Returns: VerseCount object containing the number of verses
    /// - Throws: APIError if the request fails
    public func getVerseCount(bookId: String, chapter: Int, language: String = "english") async throws -> VerseCount {
        let endpoint = "/GetVerseCount"
        let queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "chapter", value: String(chapter)),
            URLQueryItem(name: "language", value: language)
        ]
        
        let verseCount: VerseCount = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return verseCount
    }
    
    /// Get a specific verse or passage
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - chapter: The chapter number
    ///   - verse: The verse number (optional for whole chapter)
    ///   - endChapter: End chapter for range (optional)
    ///   - endVerse: End verse for range (optional)
    ///   - language: The language (default: "english")
    /// - Returns: BiblePassage object containing the text
    /// - Throws: APIError if the request fails
    public func getPassage(
        bookId: String,
        chapter: Int,
        verse: Int? = nil,
        endChapter: Int? = nil,
        endVerse: Int? = nil,
        language: String = "english"
    ) async throws -> BiblePassage {
        let endpoint = "/GetVerse"
        var queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "chapter", value: String(chapter)),
            URLQueryItem(name: "language", value: language)
        ]
        
        if let verse = verse {
            queryItems.append(URLQueryItem(name: "verse", value: String(verse)))
        }
        
        if let endChapter = endChapter {
            queryItems.append(URLQueryItem(name: "endChapter", value: String(endChapter)))
        }
        
        if let endVerse = endVerse {
            queryItems.append(URLQueryItem(name: "endVerse", value: String(endVerse)))
        }
        
        let passage: BiblePassage = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return passage
    }
    
    // MARK: - Search Methods
    
    /// Search for Bible text containing specific keywords
    /// - Parameters:
    ///   - query: The search query/keywords
    ///   - language: The language (default: "english")
    ///   - version: Bible version/translation (optional)
    ///   - limit: Maximum number of results (optional)
    /// - Returns: An array of SearchResult objects
    /// - Throws: APIError if the request fails
    public func search(
        query: String,
        language: String = "english",
        version: String? = nil,
        limit: Int? = nil
    ) async throws -> [SearchResult] {
        let endpoint = "/Search"
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "language", value: language)
        ]
        
        if let version = version {
            queryItems.append(URLQueryItem(name: "version", value: version))
        }
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        let results: [SearchResult] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return results
    }
    
    /// Search for Bible passages by reference pattern
    /// - Parameters:
    ///   - reference: Bible reference (e.g., "John 3:16", "Genesis 1:1-5")
    ///   - language: The language (default: "english")
    ///   - version: Bible version/translation (optional)
    /// - Returns: An array of BiblePassage objects
    /// - Throws: APIError if the request fails
    public func searchByReference(
        reference: String,
        language: String = "english",
        version: String? = nil
    ) async throws -> [BiblePassage] {
        let endpoint = "/SearchByReference"
        var queryItems = [
            URLQueryItem(name: "reference", value: reference),
            URLQueryItem(name: "language", value: language)
        ]
        
        if let version = version {
            queryItems.append(URLQueryItem(name: "version", value: version))
        }
        
        let results: [BiblePassage] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return results
    }
    
    // MARK: - Version and Language Methods
    
    /// Get all available Bible versions/translations
    /// - Parameter language: The language (default: "english")
    /// - Returns: An array of BibleVersion objects
    /// - Throws: APIError if the request fails
    public func getVersions(language: String = "english") async throws -> [BibleVersion] {
        let endpoint = "/GetVersions"
        let queryItems = [URLQueryItem(name: "language", value: language)]
        
        let versions: [BibleVersion] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return versions
    }
    
    /// Get all available languages
    /// - Returns: An array of Language objects
    /// - Throws: APIError if the request fails
    public func getLanguages() async throws -> [Language] {
        let endpoint = "/GetLanguages"
        
        let languages: [Language] = try await performRequest(endpoint: endpoint, queryItems: [])
        return languages
    }
    
    // MARK: - Discovery Methods
    
    /// Get a random Bible verse
    /// - Parameters:
    ///   - language: The language (default: "english")
    ///   - version: Bible version/translation (optional)
    ///   - testament: Filter by testament (optional: "old", "new")
    /// - Returns: A RandomVerse object
    /// - Throws: APIError if the request fails
    public func getRandomVerse(
        language: String = "english",
        version: String? = nil,
        testament: String? = nil
    ) async throws -> RandomVerse {
        let endpoint = "/GetRandomVerse"
        var queryItems = [URLQueryItem(name: "language", value: language)]
        
        if let version = version {
            queryItems.append(URLQueryItem(name: "version", value: version))
        }
        
        if let testament = testament {
            queryItems.append(URLQueryItem(name: "testament", value: testament))
        }
        
        let randomVerse: RandomVerse = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return randomVerse
    }
    
    /// Get the verse of the day
    /// - Parameters:
    ///   - language: The language (default: "english")
    ///   - version: Bible version/translation (optional)
    /// - Returns: A VerseOfTheDay object
    /// - Throws: APIError if the request fails
    public func getVerseOfTheDay(
        language: String = "english",
        version: String? = nil
    ) async throws -> VerseOfTheDay {
        let endpoint = "/GetVerseOfTheDay"
        var queryItems = [URLQueryItem(name: "language", value: language)]
        
        if let version = version {
            queryItems.append(URLQueryItem(name: "version", value: version))
        }
        
        let verseOfTheDay: VerseOfTheDay = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return verseOfTheDay
    }
    
    /// Get popular or frequently referenced verses
    /// - Parameters:
    ///   - language: The language (default: "english")
    ///   - version: Bible version/translation (optional)
    ///   - limit: Maximum number of results (optional)
    /// - Returns: An array of PopularVerse objects
    /// - Throws: APIError if the request fails
    public func getPopularVerses(
        language: String = "english",
        version: String? = nil,
        limit: Int? = nil
    ) async throws -> [PopularVerse] {
        let endpoint = "/GetPopularVerses"
        var queryItems = [URLQueryItem(name: "language", value: language)]
        
        if let version = version {
            queryItems.append(URLQueryItem(name: "version", value: version))
        }
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        let popularVerses: [PopularVerse] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return popularVerses
    }
    
    // MARK: - Reference and Study Methods
    
    /// Get cross-references for a specific verse
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - chapter: The chapter number
    ///   - verse: The verse number
    ///   - language: The language (default: "english")
    /// - Returns: An array of CrossReference objects
    /// - Throws: APIError if the request fails
    public func getCrossReferences(
        bookId: String,
        chapter: Int,
        verse: Int,
        language: String = "english"
    ) async throws -> [CrossReference] {
        let endpoint = "/GetCrossReferences"
        let queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "chapter", value: String(chapter)),
            URLQueryItem(name: "verse", value: String(verse)),
            URLQueryItem(name: "language", value: language)
        ]
        
        let crossReferences: [CrossReference] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return crossReferences
    }
    
    /// Get commentary for a specific verse or passage
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - chapter: The chapter number
    ///   - verse: The verse number (optional for chapter commentary)
    ///   - language: The language (default: "english")
    ///   - commentaryType: Type of commentary (optional)
    /// - Returns: A Commentary object
    /// - Throws: APIError if the request fails
    public func getCommentary(
        bookId: String,
        chapter: Int,
        verse: Int? = nil,
        language: String = "english",
        commentaryType: String? = nil
    ) async throws -> Commentary {
        let endpoint = "/GetCommentary"
        var queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "chapter", value: String(chapter)),
            URLQueryItem(name: "language", value: language)
        ]
        
        if let verse = verse {
            queryItems.append(URLQueryItem(name: "verse", value: String(verse)))
        }
        
        if let commentaryType = commentaryType {
            queryItems.append(URLQueryItem(name: "type", value: commentaryType))
        }
        
        let commentary: Commentary = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return commentary
    }
    
    /// Get topical index entries for a keyword
    /// - Parameters:
    ///   - keyword: The keyword to search for
    ///   - language: The language (default: "english")
    /// - Returns: An array of TopicalEntry objects
    /// - Throws: APIError if the request fails
    public func getTopicalIndex(
        keyword: String,
        language: String = "english"
    ) async throws -> [TopicalEntry] {
        let endpoint = "/GetTopicalIndex"
        let queryItems = [
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "language", value: language)
        ]
        
        let topicalEntries: [TopicalEntry] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return topicalEntries
    }
    
    /// Get concordance entries for a word
    /// - Parameters:
    ///   - word: The word to search for
    ///   - language: The language (default: "english")
    ///   - limit: Maximum number of results (optional)
    /// - Returns: An array of ConcordanceEntry objects
    /// - Throws: APIError if the request fails
    public func getConcordance(
        word: String,
        language: String = "english",
        limit: Int? = nil
    ) async throws -> [ConcordanceEntry] {
        let endpoint = "/GetConcordance"
        var queryItems = [
            URLQueryItem(name: "word", value: word),
            URLQueryItem(name: "language", value: language)
        ]
        
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        
        let concordanceEntries: [ConcordanceEntry] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return concordanceEntries
    }
    
    // MARK: - Metadata Methods
    
    /// Get detailed information about a specific book
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - language: The language (default: "english")
    /// - Returns: A BookInfo object with detailed information
    /// - Throws: APIError if the request fails
    public func getBookInfo(
        bookId: String,
        language: String = "english"
    ) async throws -> BookInfo {
        let endpoint = "/GetBookInfo"
        let queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "language", value: language)
        ]
        
        let bookInfo: BookInfo = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return bookInfo
    }
    
    /// Get information about a specific chapter
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - chapter: The chapter number
    ///   - language: The language (default: "english")
    /// - Returns: A ChapterInfo object
    /// - Throws: APIError if the request fails
    public func getChapterInfo(
        bookId: String,
        chapter: Int,
        language: String = "english"
    ) async throws -> ChapterInfo {
        let endpoint = "/GetChapterInfo"
        let queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "chapter", value: String(chapter)),
            URLQueryItem(name: "language", value: language)
        ]
        
        let chapterInfo: ChapterInfo = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return chapterInfo
    }
    
    // MARK: - Audio Methods
    
    /// Get audio URL for a specific verse
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - chapter: The chapter number
    ///   - verse: The verse number
    ///   - language: The language (default: "english")
    ///   - voice: Voice/narrator preference (optional)
    /// - Returns: An AudioVerse object with audio URL
    /// - Throws: APIError if the request fails
    public func getAudioVerse(
        bookId: String,
        chapter: Int,
        verse: Int,
        language: String = "english",
        voice: String? = nil
    ) async throws -> AudioVerse {
        let endpoint = "/GetAudioVerse"
        var queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "chapter", value: String(chapter)),
            URLQueryItem(name: "verse", value: String(verse)),
            URLQueryItem(name: "language", value: language)
        ]
        
        if let voice = voice {
            queryItems.append(URLQueryItem(name: "voice", value: voice))
        }
        
        let audioVerse: AudioVerse = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return audioVerse
    }
    
    /// Get audio URL for an entire chapter
    /// - Parameters:
    ///   - bookId: The ID of the book
    ///   - chapter: The chapter number
    ///   - language: The language (default: "english")
    ///   - voice: Voice/narrator preference (optional)
    /// - Returns: An AudioChapter object with audio URL
    /// - Throws: APIError if the request fails
    public func getAudioChapter(
        bookId: String,
        chapter: Int,
        language: String = "english",
        voice: String? = nil
    ) async throws -> AudioChapter {
        let endpoint = "/GetAudioChapter"
        var queryItems = [
            URLQueryItem(name: "book", value: bookId),
            URLQueryItem(name: "chapter", value: String(chapter)),
            URLQueryItem(name: "language", value: language)
        ]
        
        if let voice = voice {
            queryItems.append(URLQueryItem(name: "voice", value: voice))
        }
        
        let audioChapter: AudioChapter = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return audioChapter
    }
    
    // MARK: - Private Methods
    
    /// Perform a generic API request
    /// - Parameters:
    ///   - endpoint: The API endpoint to call
    ///   - queryItems: Query parameters for the request
    /// - Returns: Decoded response of the specified type
    /// - Throws: APIError if the request fails
    private func performRequest<T: Codable>(
        endpoint: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        guard let baseURL = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue("iq-bible.p.rapidapi.com", forHTTPHeaderField: "x-rapidapi-host")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
            
        } catch is DecodingError {
            throw APIError.decodingError
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Error Handling

/// Errors that can occur when using the IQ Bible API
public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Additional Models

/// Represents a Bible passage with text content
public struct BiblePassage: Codable {
    public let text: String
    public let reference: String?
    
    enum CodingKeys: String, CodingKey {
        case text = "text"
        case reference = "reference"
    }
    
    public init(text: String, reference: String? = nil) {
        self.text = text
        self.reference = reference
    }
}

/// Represents a search result
public struct SearchResult: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
    
    enum CodingKeys: String, CodingKey {
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verse = "verse"
        case text = "text"
        case reference = "reference"
    }
    
    public init(bookId: String, bookName: String, chapter: Int, verse: Int, text: String, reference: String) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.reference = reference
    }
}

/// Represents a Bible version/translation
public struct BibleVersion: Codable {
    public let id: String
    public let name: String
    public let abbreviation: String
    public let language: String
    public let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case abbreviation = "abbreviation"
        case language = "language"
        case description = "description"
    }
    
    public init(id: String, name: String, abbreviation: String, language: String, description: String? = nil) {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.language = language
        self.description = description
    }
}

/// Represents a language
public struct Language: Codable {
    public let code: String
    public let name: String
    public let nativeName: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
        case nativeName = "nativeName"
    }
    
    public init(code: String, name: String, nativeName: String? = nil) {
        self.code = code
        self.name = name
        self.nativeName = nativeName
    }
}

/// Represents a random verse
public struct RandomVerse: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
    
    enum CodingKeys: String, CodingKey {
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verse = "verse"
        case text = "text"
        case reference = "reference"
    }
    
    public init(bookId: String, bookName: String, chapter: Int, verse: Int, text: String, reference: String) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.reference = reference
    }
}

/// Represents the verse of the day
public struct VerseOfTheDay: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
    public let date: String
    public let theme: String?
    
    enum CodingKeys: String, CodingKey {
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verse = "verse"
        case text = "text"
        case reference = "reference"
        case date = "date"
        case theme = "theme"
    }
    
    public init(bookId: String, bookName: String, chapter: Int, verse: Int, text: String, reference: String, date: String, theme: String? = nil) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.reference = reference
        self.date = date
        self.theme = theme
    }
}

/// Represents a popular verse
public struct PopularVerse: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let text: String
    public let reference: String
    public let popularity: Int?
    
    enum CodingKeys: String, CodingKey {
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verse = "verse"
        case text = "text"
        case reference = "reference"
        case popularity = "popularity"
    }
    
    public init(bookId: String, bookName: String, chapter: Int, verse: Int, text: String, reference: String, popularity: Int? = nil) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.text = text
        self.reference = reference
        self.popularity = popularity
    }
}

/// Represents a cross-reference
public struct CrossReference: Codable {
    public let fromReference: String
    public let toBookId: String
    public let toBookName: String
    public let toChapter: Int
    public let toVerse: Int
    public let toReference: String
    public let relationType: String?
    
    enum CodingKeys: String, CodingKey {
        case fromReference = "fromReference"
        case toBookId = "toBookId"
        case toBookName = "toBookName"
        case toChapter = "toChapter"
        case toVerse = "toVerse"
        case toReference = "toReference"
        case relationType = "relationType"
    }
    
    public init(fromReference: String, toBookId: String, toBookName: String, toChapter: Int, toVerse: Int, toReference: String, relationType: String? = nil) {
        self.fromReference = fromReference
        self.toBookId = toBookId
        self.toBookName = toBookName
        self.toChapter = toChapter
        self.toVerse = toVerse
        self.toReference = toReference
        self.relationType = relationType
    }
}

/// Represents commentary content
public struct Commentary: Codable {
    public let reference: String
    public let title: String?
    public let content: String
    public let author: String?
    public let source: String?
    public let type: String?
    
    enum CodingKeys: String, CodingKey {
        case reference = "reference"
        case title = "title"
        case content = "content"
        case author = "author"
        case source = "source"
        case type = "type"
    }
    
    public init(reference: String, title: String? = nil, content: String, author: String? = nil, source: String? = nil, type: String? = nil) {
        self.reference = reference
        self.title = title
        self.content = content
        self.author = author
        self.source = source
        self.type = type
    }
}

/// Represents a topical index entry
public struct TopicalEntry: Codable {
    public let keyword: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let reference: String
    public let context: String?
    
    enum CodingKeys: String, CodingKey {
        case keyword = "keyword"
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verse = "verse"
        case reference = "reference"
        case context = "context"
    }
    
    public init(keyword: String, bookId: String, bookName: String, chapter: Int, verse: Int, reference: String, context: String? = nil) {
        self.keyword = keyword
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.reference = reference
        self.context = context
    }
}

/// Represents a concordance entry
public struct ConcordanceEntry: Codable {
    public let word: String
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let reference: String
    public let context: String
    public let occurrence: Int?
    
    enum CodingKeys: String, CodingKey {
        case word = "word"
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verse = "verse"
        case reference = "reference"
        case context = "context"
        case occurrence = "occurrence"
    }
    
    public init(word: String, bookId: String, bookName: String, chapter: Int, verse: Int, reference: String, context: String, occurrence: Int? = nil) {
        self.word = word
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.reference = reference
        self.context = context
        self.occurrence = occurrence
    }
}

/// Represents detailed book information
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
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case fullName = "fullName"
        case testament = "testament"
        case chapterCount = "chapterCount"
        case author = "author"
        case writtenDate = "writtenDate"
        case summary = "summary"
        case genre = "genre"
    }
    
    public init(id: String, name: String, fullName: String? = nil, testament: String, chapterCount: Int, author: String? = nil, writtenDate: String? = nil, summary: String? = nil, genre: String? = nil) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.testament = testament
        self.chapterCount = chapterCount
        self.author = author
        self.writtenDate = writtenDate
        self.summary = summary
        self.genre = genre
    }
}

/// Represents chapter information
public struct ChapterInfo: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verseCount: Int
    public let title: String?
    public let summary: String?
    public let theme: String?
    
    enum CodingKeys: String, CodingKey {
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verseCount = "verseCount"
        case title = "title"
        case summary = "summary"
        case theme = "theme"
    }
    
    public init(bookId: String, bookName: String, chapter: Int, verseCount: Int, title: String? = nil, summary: String? = nil, theme: String? = nil) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verseCount = verseCount
        self.title = title
        self.summary = summary
        self.theme = theme
    }
}

/// Represents audio verse information
public struct AudioVerse: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let verse: Int
    public let reference: String
    public let audioUrl: String
    public let duration: Double?
    public let voice: String?
    
    enum CodingKeys: String, CodingKey {
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case verse = "verse"
        case reference = "reference"
        case audioUrl = "audioUrl"
        case duration = "duration"
        case voice = "voice"
    }
    
    public init(bookId: String, bookName: String, chapter: Int, verse: Int, reference: String, audioUrl: String, duration: Double? = nil, voice: String? = nil) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.reference = reference
        self.audioUrl = audioUrl
        self.duration = duration
        self.voice = voice
    }
}

/// Represents audio chapter information
public struct AudioChapter: Codable {
    public let bookId: String
    public let bookName: String
    public let chapter: Int
    public let audioUrl: String
    public let duration: Double?
    public let voice: String?
    public let verseTimestamps: [VerseTimestamp]?
    
    enum CodingKeys: String, CodingKey {
        case bookId = "bookId"
        case bookName = "bookName"
        case chapter = "chapter"
        case audioUrl = "audioUrl"
        case duration = "duration"
        case voice = "voice"
        case verseTimestamps = "verseTimestamps"
    }
    
    public init(bookId: String, bookName: String, chapter: Int, audioUrl: String, duration: Double? = nil, voice: String? = nil, verseTimestamps: [VerseTimestamp]? = nil) {
        self.bookId = bookId
        self.bookName = bookName
        self.chapter = chapter
        self.audioUrl = audioUrl
        self.duration = duration
        self.voice = voice
        self.verseTimestamps = verseTimestamps
    }
}

/// Represents a verse timestamp for audio
public struct VerseTimestamp: Codable {
    public let verse: Int
    public let startTime: Double
    public let endTime: Double
    
    enum CodingKeys: String, CodingKey {
        case verse = "verse"
        case startTime = "startTime"
        case endTime = "endTime"
    }
    
    public init(verse: Int, startTime: Double, endTime: Double) {
        self.verse = verse
        self.startTime = startTime
        self.endTime = endTime
    }
}