//
//  NewsAPIMapping.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

enum NewsAPIMapping {
    private static let iso8601WithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static func newsPage(from dto: NewsAPIResponseDTO) throws -> NewsPage {
        guard dto.status == "ok" else {
            throw NewsFeedError.apiStatus(
                code: nil,
                message: dto.message ?? dto.code ?? "Unknown API Error"
            )
        }

        let articles = (dto.articles ?? []).compactMap(article(from:))
        return NewsPage(
            articles: articles,
            totalResults: dto.totalResults ?? articles.count
        )
    }

    static func article(from dto: ArticleDTO) -> Article? {
        guard let title = dto.title, !title.isEmpty,
              let url = dto.url, !url.isEmpty
        else {
            return nil
        }

        return Article(
            title: title,
            url: url,
            urlToImage: dto.urlToImage,
            description: dto.description,
            author: dto.author,
            publishedDate: dto.publishedAt.flatMap(parseDate),
            sourceName: dto.source?.name
        )
    }

    private static func parseDate(_ string: String) -> Date? {
        iso8601WithFractional.date(from: string) ??
        iso8601.date(from: string)
    }
}
