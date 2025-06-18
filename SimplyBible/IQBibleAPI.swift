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
}