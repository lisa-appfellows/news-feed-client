//
//  NewsAPIURLBuilder.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

enum NewsAPIURLBuilder {
    private static let baseURL = URL(string: "https://newsapi.org/v2")!

    static func topHeadlines(_ request: TopHeadlinesRequest) -> URL {
        var items: [URLQueryItem] = [
            .init(name: "country", value: request.country),
            .init(name: "pageSize", value: String(request.pageSize)),
            .init(name: "page", value: String(request.page))
        ]

        if let category = request.category {
            items.append(.init(name: "category", value: category.rawValue))
        }

        return url(path: "top-headlines", items: items)
    }

    static func everything(_ request: EverythingRequest) -> URL {
        var items: [URLQueryItem] = [
            .init(name: "q", value: request.q),
            .init(name: "pageSize", value: String(request.pageSize)),
            .init(name: "page", value: String(request.page))
        ]

        if let from = request.from {
            items.append(.init(name: "from", value: formatDate(from)))
        }
        if let to = request.to {
            items.append(.init(name: "to", value: formatDate(to)))
        }
        if let language = request.language {
            items.append(.init(name: "language", value: language))
        }
        if let sortBy = request.sortBy {
            items.append(.init(name: "sortBy", value: sortBy.rawValue))
        }

        return url(path: "everything", items: items)
    }

    private static func url(path: String, items: [URLQueryItem]) -> URL {
        var components = URLComponents(
            url: baseURL.appending(path: path),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = items
        return components.url!
    }

    private static let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
