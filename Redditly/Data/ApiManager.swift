//
//  ApiManager.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

class ApiManager: ArticleDataProvider {
    var baseURL: String { "https://www.reddit.com/r/swift/.json" }

    private let defaultSession = URLSession(configuration: .default)

    private var dataTask: URLSessionDataTask?

    func getArticles(after: String?, completion: @escaping (ArticleParseResult) -> Void) {
        guard let baseURL = URL(string: baseURL) else {
            completion(.failure(.invalidBaseURL))
            return
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)

        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "after", value: after))
        queryItems.append(URLQueryItem(name: "raw_json", value: "1"))

        components?.queryItems = queryItems

        // Cancel any previously running tasks (because of simplicity of app, we know that only one employee list download should be happening at a time)
        dataTask?.cancel()

        guard let url = components?.url else {
            completion(.failure(.invalidBaseURL))
            return
        }

        let request = URLRequest(url: url)

        dataTask = defaultSession.dataTask(with: request) { data, response, error in
            let result = self.parseArticleData(data, error: error)
            completion(result)
        }

        dataTask?.resume()
    }

    func getImageData(with url: URL, completion: @escaping (Result<Data, DataProviderError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.noData(error)))
            }
        }

        task.resume()
    }
}
