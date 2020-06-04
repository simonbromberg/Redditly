//
//  ApiManager.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import Foundation

class ApiManager {
    static var shared = ApiManager()

    var baseURL: String { "https://www.reddit.com/r/swift/.json" }

    private let defaultSession = URLSession(configuration: .default)

    private var dataTask: URLSessionDataTask?

    func getArticles(_ completion: @escaping (Result<[Article], NetworkError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidBaseURL))
            return
        }

        // Cancel any previously running tasks (because of simplicity of app, we know that only one employee list download should be happening at a time)
        dataTask?.cancel()

        let request = URLRequest(url: url)

        dataTask = defaultSession.dataTask(with: request) { data, response, error in
            let result = self.parseArticleData(data, error: error)
            completion(result)
        }

        dataTask?.resume()
    }

    func parseArticleData(_ data: Data?, error: Error?) -> Result<[Article], NetworkError> {
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

    func getImageData(_ url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(.noData(error)))
            }
        }

        task.resume()
    }

    enum NetworkError: Error {
        case invalidBaseURL
        case noData(Error?)
        case decodingFailure(Error?)
    }
}
