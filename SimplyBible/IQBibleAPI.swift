//
//  IQBibleAPI.swift
//  SimplyBible
//
//  Created by Andrew Baughman on 6/18/25.
//

import Foundation

class IQBibleAPI {
    private let baseURL = "https://iq-bible.p.rapidapi.com"
    private let apiKey: String
    private let session: URLSession
    private let bibleVersion = "kjv"
    
    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case httpError(Int)
        case decodingError
        case networkError(Error)

        var errorDescription: String? {
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

            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }

                guard 200...299 ~= httpResponse.statusCode else {
                    throw APIError.httpError(httpResponse.statusCode)
                }

                let decoder = JSONDecoder()
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                }
                let result = try decoder.decode(T.self, from: data)
                return result

            } catch is DecodingError {
                throw APIError.decodingError
            } catch {
                throw APIError.networkError(error)
            }
        }
    
    func getBooks(language: String = "english") async throws -> [Book] {
        let endpoint = "/GetBooks"
        let queryItems = [URLQueryItem(name: "language", value: language)]

        let books: [Book] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return books
    }
    
    func getChapterCount(bookId: String, language: String = "english") async throws -> Int {
        let endpoint = "/GetChapterCount"
        let queryItems = [
            URLQueryItem(name: "bookId", value: bookId),
            URLQueryItem(name: "language", value: language)
        ]

        let chapterCount: ChapterCount = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return chapterCount.chapterCount
    }
    
    func getVerseCount(bookId: String, chapter: Int, language: String = "english") async throws -> Int {
        let endpoint = "/GetVerseCount"
        let queryItems = [
            URLQueryItem(name: "bookId", value: bookId),
            URLQueryItem(name: "chapterId", value: String(chapter)),
            URLQueryItem(name: "language", value: language)
        ]

        let verseCount: VerseCount = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return verseCount.verseCount
    }
    
    func getChapter(bookId: String, chapter: Int, language: String = "english") async throws -> [VerseData] {
        let endpoint = "/GetChapter"
        let queryItems = [
            URLQueryItem(name: "bookId", value: bookId),
            URLQueryItem(name: "chapterId", value: String(chapter)),
            URLQueryItem(name: "versionId", value: bibleVersion),
            URLQueryItem(name: "language", value: language)
        ]

        let passage: [VerseData] = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return passage
    }
    
    func getVerse(verse: String) async throws -> VerseData {
        let endpoint = "/GetVerse"
        let queryItems = [
            URLQueryItem(name: "verseId", value: verse),
            URLQueryItem(name: "versionId", value: bibleVersion)
        ]

        let passage: VerseData = try await performRequest(endpoint: endpoint, queryItems: queryItems)
        return passage
    }
}
