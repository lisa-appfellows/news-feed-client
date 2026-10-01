//
//  NewsAPIURLBuilderTests.swift
//  
//
//  Created by Lisa Fellows on 2026-09-30.
//

import XCTest
@testable import NewsFeedClient

final class NewsAPIURLBuilderTests: XCTestCase {
    func testTopHeadlinesOmitsNilCategory() {
        let url = NewsAPIURLBuilder.topHeadlines(
            TopHeadlinesRequest(country: "us", pageSize: 4, page: 1)
        )
        let items = queryItems(url)

        XCTAssertEqual(items["country"], "us")
        XCTAssertEqual(items["pageSize"], "4")
        XCTAssertEqual(items["page"], "1")
        XCTAssertTrue(url.path.hasSuffix("/top-headlines"))
    }

    func testTopHeadlinesIncludesCategory() {
        let url = NewsAPIURLBuilder.topHeadlines(
            TopHeadlinesRequest(country: "us", category: .technology)
        )
        XCTAssertEqual(queryItems(url)["category"], NewsCategory.technology.rawValue)
    }

    func testEverythingIncludesOptionals() {
        let from = Date(timeIntervalSince1970: 1_718_000_000) // fixed instant
        let url = NewsAPIURLBuilder.everything(
            EverythingRequest(
                q: "swift",
                from: from,
                language: "en",
                sortBy: .publishedAt,
                pageSize: 20,
                page: 2
            )
        )
        let items = queryItems(url)

        XCTAssertEqual(items["q"], "swift")
        XCTAssertEqual(items["language"], "en")
        XCTAssertEqual(items["sortBy"], SortBy.publishedAt.rawValue)
        XCTAssertEqual(items["pageSize"], "20")
        XCTAssertEqual(items["page"], "2")
        XCTAssertNotNil(items["from"])
        XCTAssertNil(items["to"])
        XCTAssertTrue(url.path.hasSuffix("/everything"))
    }

    private func queryItems(_ url: URL) -> [String: String] {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: String]()) { result, item in
                result[item.name] = item.value
            } ?? [:]
    }
}
