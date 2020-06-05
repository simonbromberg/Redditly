//
//  Models.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

struct Listing: Decodable {
    let data: ListingData

    struct ListingData: Decodable {
        let children: [ArticleData]
        let after: String?
        let before: String?
    }
}

struct ArticleData: Decodable {
    let kind: String
    let data: Article
}

struct Article: Decodable {
    let id: String
    
    let title: String

    let body: String
    let bodyHTML: String?

    let url: String?
    var articleURL: URL? {
        return url.flatMap { URL(string: $0) }
    }
    
    let thumbnail: String?
    var thumbnailURL: URL? {
        return thumbnail.flatMap { URL(string: $0) }
    }

    let thumbnailHeight: Float?
    let thumbnailWidth: Float?

    let score: Int
    let upvoteRatio: Float
    
    let createdUTC: Double
    var createdDate: Date { Date(timeIntervalSince1970: createdUTC) }

    var hasThumbnail: Bool {
        return thumbnail != nil &&
            (thumbnailHeight ?? 0) > 0 &&
            (thumbnailWidth ?? 0) > 0
    }

    enum CodingKeys: String, CodingKey {
        case body = "selftext"
        case bodyHTML = "selftextHtml"
        case createdUTC = "createdUtc"
        case id, title, thumbnail, thumbnailHeight, thumbnailWidth, url, score, upvoteRatio
    }
}
