//
//  TopHeadlinesRequest.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

public struct TopHeadlinesRequest: Equatable, Sendable {
    public let country: String
    public let category: String?
    public let pageSize: Int
    public let page: Int

    public init(
        country: String,
        category: String? = nil,
        pageSize: Int = 20,
        page: Int = 1
    ) {
        self.country = country
        self.category = category
        self.pageSize = pageSize
        self.page = page
    }
}
