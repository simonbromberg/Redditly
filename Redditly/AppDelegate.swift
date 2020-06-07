//
//  AppDelegate.swift
//  Redditly
//
//  Created by Simon Bromberg on 2020-06-04.
//  Copyright © 2020 SBromberg. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        if isRunningTests {
            let mockApiManager = MockApiManager()
            mockApiManager.articleData = articleDataForCommandLineArguments()
            mockApiManager.imageData = UIImage(named: "sample_image")?.jpegData(compressionQuality: 1)

            DataProvider.shared = mockApiManager
        }
        #endif

        return true
    }

    #if DEBUG
    // MARK: - Tests

    /// Check environment variables for testing flag
    var isRunningTests: Bool {
        return CommandLine.arguments.contains("-running_tests")
    }

    /// Modify mock api for bad data
    private func articleDataForCommandLineArguments() -> Data? {
        var resourceName: String?
        if CommandLine.arguments.contains("-empty_data") {
            resourceName = "TestDataEmpty"
        } else {
            resourceName = "TestData"
        }

        if let name = resourceName,
            let url = Bundle.main.url(forResource: name, withExtension: "json") {
            return try? Data(contentsOf: url)
        }

        return nil
    }
    #endif
}

