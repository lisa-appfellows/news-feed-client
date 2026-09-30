//
//  NewsAPIMappingTests.swift
//  
//
//  Created by Lisa Fellows on 2026-09-30.
//

import XCTest
@testable import NewsFeedClient

final class NewsAPIMappingTests: XCTestCase {
    func testMapsSuccessfulResponse() throws {
        let json = """
        {
          "status": "ok",
          "totalResults": 2,
          "articles": [
           {
              "source": { "id": "techcrunch", "name": "TechCrunch" },
              "author": "Jane Doe",
              "title": "Hello",
              "description": "A story",
              "url": "https://example.com/a",
              "urlToImage": "https://example.com/a.jpg",
              "publishedAt": "2024-06-01T12:30:00Z"
            },
            {
              "source": { "id": null, "name": "Wired" },
              "author": null,
              "title": "World",
              "description": null,
              "url": "https://example.com/b",
              "urlToImage": null,
              "publishedAt": "2024-06-01T12:30:00.500Z"
            }
          ]
        }
        """

        let dto = try decode(json)
        let page = try NewsAPIMapping.newsPage(from: dto)

        XCTAssertEqual(page.totalResults, 2)
        XCTAssertEqual(page.articles.count, 2)

        let first = page.articles[0]
        XCTAssertEqual(first.title, "Hello")
        XCTAssertEqual(first.url, "https://example.com/a")
        XCTAssertEqual(first.urlToImage, "https://example.com/a.jpg")
        XCTAssertEqual(first.description, "A story")
        XCTAssertEqual(first.author, "Jane Doe")
        XCTAssertNotNil(first.publishedDate)

        let second = page.articles[1]
        XCTAssertEqual(second.sourceName, "Wired")
        XCTAssertNil(second.author)
        XCTAssertNil(second.urlToImage)
        XCTAssertNotNil(second.publishedDate)
        
    }

    func testDropsArticlesMissingTitleOrURL() throws {
        let json = """
        {
          "status": "ok",
          "totalResults": 3,
          "articles": [
           {
              "title": "",
              "url": "https://example.com/empty-title"
            },
            {
              "title": "No URL",
              "url": ""
            },
            {
              "title": "Keep me",
              "url": "https://example.com/keep"
            },
          ]
        }
        """

        let page = try NewsAPIMapping.newsPage(from: try decode(json))

        XCTAssertEqual(page.articles.count, 1)
        XCTAssertEqual(page.articles[0].title, "Keep me")
        // NewsAPI's totalResults is preserved even when rows dropped.
        XCTAssertEqual(page.totalResults, 3)
    }

    func testErrorStatusThrowsAPIStatus() throws {
        let json = """
        {
          "status": "error",
          "code": "apiKeyInvalid",
          "message": "Your API key is invalid"
        }
        """

        XCTAssertThrowsError(
            try NewsAPIMapping.newsPage(from: try decode(json))
        ) { error in
            guard case NewsFeedError.apiStatus(_, let message) = error else {
                return XCTFail("Expected apiStatus, got \(error)")
            }
            XCTAssertEqual(message, "Your API key is invalid")
        }
    }

    private func decode(_ json: String) throws -> NewsAPIResponseDTO {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(NewsAPIResponseDTO.self, from: data)
    }
}
