//
//  Article.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

public struct Article: Equatable, Sendable {
    public let title: String
    public let url: String
    public let urlToImage: String?
    public let description: String?
    public let author: String?
    public let publishedDate: Date?
    public let sourceName: String?

    public init(
        title: String,
        url: String,
        urlToImage: String? = nil,
        description: String? = nil,
        author: String? = nil,
        publishedDate: Date? = nil,
        sourceName: String? = nil
    ) {
        self.title = title
        self.url = url
        self.urlToImage = urlToImage
        self.description = description
        self.author = author
        self.publishedDate = publishedDate
        self.sourceName = sourceName
    }
}
