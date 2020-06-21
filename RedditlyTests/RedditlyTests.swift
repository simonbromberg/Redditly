//
//  RedditlyTests.swift
//  RedditlyTests
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import XCTest
@testable import Redditly

class RedditlyTests: XCTestCase {

    func testNormalListingJSON() {
        guard let data = loadDataFromJSONResource("TestData") else {
            return
        }

        let exp = expectation(description: "Mock API")

        let apiManager = MockApiManager()
        apiManager.articleData = data

        apiManager.getArticles(after: nil) { result in
            do {
                switch result {
                case .success(let articleResult):
                    let articles = articleResult.articles
                    XCTAssertEqual(articles.count, 26, "Number of articles does not match test data")

                    let article = try XCTUnwrap(articles.first, "Unable to get first article")
                    XCTAssertEqual(article.title, "What’s everyone working on this month? (June 2020)", "Title mismatch")
                    XCTAssertEqual(article.score, 14, "Score mismatch")
                    XCTAssertEqual(article.createdDate.timeIntervalSince1970, 1591042067, "Date mismatch")
                case .failure(let error):
                    XCTFail("Get articles returned error: \(error.localizedDescription)")
                }
            } catch { }

            exp.fulfill()
        }

        waitForExpectations(timeout: 10)
    }


    // MARK: - Helper

    private func loadDataFromJSONResource(_ filename: String, file: StaticString = #file, line: UInt = #line) -> Data? {
        guard let url = Bundle(for: type(of: self)).url(forResource: filename, withExtension: "json") else {
            XCTFail("Unable to extract JSON data from file \(filename)", file: file, line: line)
            return nil
        }

        do {
            return try XCTUnwrap(Data(contentsOf: url), "Data in file \(filename) was nil", file: file, line: line)
        } catch { return nil }
    }
}
