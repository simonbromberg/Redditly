//
//  RedditlyUITests.swift
//  RedditlyUITests
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import XCTest

class RedditlyUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    var app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchArguments = ["-running_tests"]
        return app
    }()

    func testLoadNormal() {
        app.launch()

        let title = app.tables.cells.element(boundBy: 0).staticTexts["What’s everyone working on this month? (June 2020)"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "Incorrect article in 1st row")

        app.tables.cells.element(boundBy: 0).tap()

        let score = app.tables.cells.element(boundBy: 2).staticTexts["Score: 14 Upvote ratio: 0.86\nJun 1, 2020 at 4:07:47 PM"]
        XCTAssertTrue(score.waitForExistence(timeout: 5), "Missing score row")

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(title.isHittable, "Back didn't work")
    }

    func testLoadEmpty() {
        app.launchArguments.append("-empty_data")
        app.launch()

        XCTAssertEqual(app.tables.cells.count, 0, "App should not load any data when json is empty")

        let errorLabel = app.staticTexts["No results"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5), "Missing error label")
        XCTAssertTrue(errorLabel.isHittable, "Error label not visible")
    }
}
