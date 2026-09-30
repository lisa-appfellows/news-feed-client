//
//  NewsAPIDTOs.swift
//
//
//  Created by Lisa Fellows on 2026-09-30.
//

import Foundation

struct NewsAPIResponseDTO: Decodable {
    let status: String
    let totalResults: Int?
    let articles: [ArticleDTO]?
    let code: String?
    let message: String?
}

struct ArticleDTO: Decodable {
    let source: SourceDTO?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
}

struct SourceDTO: Decodable {
    let id: String?
    let name: String?
}
