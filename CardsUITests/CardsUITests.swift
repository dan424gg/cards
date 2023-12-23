//
//  CardsUITests.swift
//  CardsUITests
//
//  Created by Daniel Wells on 10/11/23.
//

import XCTest

import FirebaseFirestore
import FirebaseFirestoreSwift

@testable import Cards

final class CardsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
//         delete player created in test
//        Firestore.firestore().collection("games").document("1234").delete()
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        
        let startingApp = XCUIApplication()
        startingApp.launchArguments = ["testMode"]
        startingApp.launch()
        
//        let isEnabled = NSPredicate(format: "isEnabled == true")
//        let playButton = startingApp.buttons["Play!"]
//        expectation(for: isEnabled, evaluatedWith: playButton, handler: nil)
//        waitForExpectations(timeout: 5, handler: nil)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
