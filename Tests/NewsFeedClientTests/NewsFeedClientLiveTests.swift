//
//  NewsFeedClientLiveTests.swift
//  
//
//  Created by Lisa Fellows on 2026-09-30.
//

import XCTest
@testable import NewsFeedClient

final class NewsFeedClientLiveTests: XCTestCase {
    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func testLiveTopHeadlinesDecodesPage() async throws {
        StubURLProtocol.handler = { request in
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Api-Key"), "test-key")
            XCTAssertTrue(request.url?.path.contains("top-headlines") == true)

            let body = """
            {
              "status": "ok",
              "totalResults": 1,
              "articles": [
                {
                  "source": { "name": "Example" },
                  "title": "Live title",
                  "url": "https://example.com/live"
                }
              ]
            }
            """

            return (
                HTTPURLResponse(
                    url: request.url!, 
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data(body.utf8)
            )
        }

        let client = NewsFeedClient.live(apiKey: "test-key", session: Self.stubSession())
        let page = try await client.topHeadlines(
            .init(country: "us", category: .technology)
        )

        XCTAssertEqual(page.totalResults, 1)
        XCTAssertEqual(page.articles.first?.title, "Live title")
    }

    func testLiveUnauthorized() async {
        StubURLProtocol.handler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }

        let client = NewsFeedClient.live(apiKey: "bad", session: Self.stubSession())

        do {
            _ = try await client.topHeadlines(.init(country: "us"))
            XCTFail("Expected unauthorized")
        } catch NewsFeedError.unauthorized {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLiveRateLimited() async {
        StubURLProtocol.handler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 429,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data()
            )
        }

        let client = NewsFeedClient.live(apiKey: "limited", session: Self.stubSession())

        do {
            _ = try await client.everything(.init(q: "swift"))
            XCTFail("Expected rateLimited")
        } catch NewsFeedError.rateLimited {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFixtureIgnoresNetwork() async throws {
        let expected = NewsPage(
            articles: [
                .init(title: "Fixture", url: "https://example.com")
            ], 
            totalResults: 1
        )

        let client = NewsFeedClient.fixture(expected)
        let page = try await client.topHeadlines(.init(country: "us"))
        XCTAssertEqual(page, expected)
    }

    func testLiveAPIStatusFromErrorBody() async {
        StubURLProtocol.handler = { request in
            let body = """
            {
              "status": "error",
              "code": "parametersMissing",
              "message": "Required parameters are missing."
            }
            """
    
            return (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 400,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data(body.utf8)
            )
        }

        let client = NewsFeedClient.live(apiKey: "key", session: Self.stubSession())

        do {
            _ = try await client.topHeadlines(.init(country: "us"))
            XCTFail("Expected apiStatus")
        } catch NewsFeedError.apiStatus(_, let message) {
            XCTAssertEqual(message, "Required parameters are missing.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLiveDecodingFailureOnOkResponse() async {
        StubURLProtocol.handler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data("not-json".utf8)
            )
        }

        let client = NewsFeedClient.live(apiKey: "key", session: Self.stubSession())

        do {
            _ = try await client.topHeadlines(.init(country: "us"))
            XCTFail("Expected decoding")
        } catch NewsFeedError.decoding {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLiveNonJSONErrorUsesHTTPStatus() async {
        StubURLProtocol.handler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data("Internal Server Error".utf8)
            )
        }

        let client = NewsFeedClient.live(apiKey: "key", session: Self.stubSession())

        do {
            _ = try await client.topHeadlines(.init(country: "us"))
            XCTFail("Expected apiStatus")
        } catch NewsFeedError.apiStatus(let code, _) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testLiveTransportFailure() async {
        StubURLProtocol.handler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let client = NewsFeedClient.live(apiKey: "key", session: Self.stubSession())

        do {
            _ = try await client.topHeadlines(.init(country: "us"))
            XCTFail("Expected transport")
        } catch NewsFeedError.transport {
            // expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private static func stubSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: config)
    }
}

// MARK: - StubURLProtocol
private final class StubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
           let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
