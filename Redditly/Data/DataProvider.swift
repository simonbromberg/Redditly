//
//  DataProvider.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-06.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

enum DataProviderError: Error {
    case invalidBaseURL
    case noData(Error?)
    case decodingFailure(Error?)
}

struct DataProvider {
    static var shared: ArticleDataProvider = ApiManager()
}

struct ArticleResult {
    let page: String?
    let articles: [Article]
}

protocol ArticleDataProvider {
    func getArticles(after: String?, completion: @escaping (ArticleParseResult) -> Void)

    func getImageData(with url: URL, completion: @escaping (Result<Data, DataProviderError>) -> Void)
}

extension ArticleDataProvider {
    typealias ArticleParseResult = Result<ArticleResult, DataProviderError>

    func parseArticleData(_ data: Data?, error: Error?) -> ArticleParseResult {
        guard let data = data else {
            return .failure(.noData(error))
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let results = try decoder.decode(Listing.self, from: data)
            let data = results.data
            let result = ArticleResult(page: data.after, articles: data.children.map({ $0.data }))
            return .success(result)
        } catch {
            return .failure(.decodingFailure(error))
        }
    }
}
