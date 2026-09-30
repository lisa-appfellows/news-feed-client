//
//  EverythingRequest.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

public struct EverythingRequest: Equatable, Sendable {
    public let q: String
    public let from: Date?
    public let to: Date?
    public let language: String?
    public let sortBy: SortBy?
    public let pageSize: Int
    public let page: Int

    public init(
        q: String,
        from: Date? = nil,
        to: Date? = nil,
        language: String? = nil,
        sortBy: SortBy? = nil,
        pageSize: Int = 20,
        page: Int = 1
    ) {
        self.q = q
        self.from = from
        self.to = to
        self.language = language
        self.sortBy = sortBy
        self.pageSize = pageSize
        self.page = page
    }
}
