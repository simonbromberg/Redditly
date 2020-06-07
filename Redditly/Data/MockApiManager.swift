//
//  MockApiManager.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-06.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

class MockApiManager: ArticleDataProvider {
    var articleData: Data?
    var articleError: Error?

    func getArticles(_ completion: @escaping (ArticleParseResult) -> Void) {
        let result = parseArticleData(articleData, error: articleError)
        completion(result)
    }

    var imageData: Data?
    var imageError: DataProviderError?

    func getImageData(with url: URL, completion: @escaping (Result<Data, DataProviderError>) -> Void) {
        if let data = imageData {
            completion(.success(data))
        } else {
            completion(.failure(imageError ?? .noData(nil)))
        }
    }
}
