//
//  CardsUITests.swift
//  CardsUITests
//
//  Created by Daniel Wells on 10/11/23.
//

import XCTest

import FirebaseFirestore
import FirebaseFirestoreSwift

final class CardsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        app.launch()
        app.launchArguments = ["testMode"]
        app.buttons["Cribbage"].tap()
        XCTAssert(app.buttons["Start a new game"].exists)
        XCTAssert(app.buttons["Join an existing game"].exists)
        
        app.buttons["Join an existing game"].tap()
        XCTAssert(app.staticTexts["Please enter a Group ID, and your name!"].exists)
        
        app.textFields["Group ID"].tap()
        app.typeText("1234")
        app.textFields["Full Name"].tap()
        app.typeText("Test Player")
        app.buttons["Submit"].tap()
        XCTAssert(app.staticTexts["Hi Test Player!"].exists)
        
        let isEnabled = NSPredicate(format: "isEnabled == true")
        let secondPlayButton = app.buttons["Play!"]
        expectation(for: isEnabled, evaluatedWith: secondPlayButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        app.buttons["Play!"].tap()
        XCTAssert(app.staticTexts["Cribbage"].exists)
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
