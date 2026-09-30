//
//  NewsFeedError.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

public enum NewsFeedError: Error, Equatable, Sendable {
    /// HTTP 401 - bad or missing API key
    case unauthorized

    /// HTTP 429 - NewsAPI rate limit
    case rateLimited

    /// Network / URLSession failure (offline, timeout, etc)
    case transport(String)

    /// Response body couldn't be decoded
    case decoding(String)

    /// NewsAPI returned a non-ok 'status' (or unexpected HTTP) with a message
    case apiStatus(code: Int?, message: String)
}
