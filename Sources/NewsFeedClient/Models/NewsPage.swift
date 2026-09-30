//
//  NewsPage.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

public struct NewsPage: Equatable, Sendable {
    public let articles: [Article]
    public let totalResults: Int

    public init(articles: [Article], totalResults: Int) {
        self.articles = articles
        self.totalResults = totalResults
    }
}
