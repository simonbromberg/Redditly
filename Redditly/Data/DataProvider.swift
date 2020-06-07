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

protocol ArticleDataProvider {
    func getArticles(_ completion: @escaping (ArticleParseResult) -> Void)

    func getImageData(with url: URL, completion: @escaping (Result<Data, DataProviderError>) -> Void)
}

extension ArticleDataProvider {
    typealias ArticleParseResult = Result<[Article], DataProviderError>

    func parseArticleData(_ data: Data?, error: Error?) -> ArticleParseResult {
        guard let data = data else {
            return .failure(.noData(error))
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let results = try decoder.decode(Listing.self, from: data)
            return .success(results.data.children.map({ $0.data }))
        } catch {
            return .failure(.decodingFailure(error))
        }
    }
}
