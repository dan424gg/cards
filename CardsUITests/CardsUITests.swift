//
//  CardsUITests.swift
//  CardsUITests
//
//  Created by Daniel Wells on 10/11/23.
//

import XCTest
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

@testable import CardsPlayground

final class NewGameUITests: XCTestCase {
    
    private var app: XCUIApplication!
    private var id: Int!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-testing"] // could do flood tests with -flood
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
    
    func testSubmitUnusableWithNoName() {
        app.buttons["Cribbage"].tap()
        
        let newGameBtn = app.buttons["New Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 1), "New Game Button should appear")
        newGameBtn.tap()
        
        let submitBtn = app.buttons["Submit"]
        XCTAssertTrue(submitBtn.waitForExistence(timeout: 1), "Submit Button should appear")
        XCTAssertFalse(submitBtn.isEnabled)
    }
    
    func testSubmitUsableWithName() {
        app.buttons["Cribbage"].tap()
        
        let newGameBtn = app.buttons["New Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 1), "New Game Button should appear")
        newGameBtn.tap()
        
        let fullNameTextField = app.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 1), "Full Name Text Field should appear")
        fullNameTextField.tap()
        
        app.typeText("Player One")
        let submitBtn = app.buttons["Submit"]
        XCTAssertTrue(submitBtn.isEnabled)
    }
}

final class ExistingGameUITests: XCTestCase {
    
    private var app: XCUIApplication!
    private var id: Int!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-testing"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
    }
    
    func testSubmitUsableWithNameAndGroupId() {
        app.buttons["Cribbage"].tap()
        
        let newGameBtn = app.buttons["Join Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 1), "Join Game Button should appear")
        newGameBtn.tap()
        
        let groupIdTextField = app.textFields["Group ID"]
        XCTAssertTrue(groupIdTextField.waitForExistence(timeout: 1), "Group ID Text Field should appear")
        groupIdTextField.tap()
        app.typeText("10076")
        
        let fullNameTextField = app.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 1), "Full Name Text Field should appear")
        fullNameTextField.tap()
        app.typeText("Player Two")

        let submitBtn = app.buttons["Submit"]
        XCTAssertTrue(submitBtn.isEnabled)
    }
    
    func testSubmitUnusableWithGroupIdAndNoName() {
        app.buttons["Cribbage"].tap()
        
        let newGameBtn = app.buttons["Join Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 1), "Join Game Button should appear")
        newGameBtn.tap()
        
        let groupIdTextField = app.textFields["Group ID"]
        XCTAssertTrue(groupIdTextField.waitForExistence(timeout: 1), "Group ID Text Field should appear")
        groupIdTextField.tap()
        app.typeText("10076")

        let submitBtn = app.buttons["Submit"]
        XCTAssertFalse(submitBtn.isEnabled)
    }
    
    func testSubmitUnusableWithNameAndNoGroupId() {
        app.buttons["Cribbage"].tap()
        
        let newGameBtn = app.buttons["Join Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 1), "Join Game Button should appear")
        newGameBtn.tap()
        
        let fullNameTextField = app.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 1), "Full Name Text Field should appear")
        fullNameTextField.tap()
        app.typeText("Player Two")

        let submitBtn = app.buttons["Submit"]
        XCTAssertFalse(submitBtn.isEnabled)
    }
    
    func testWarningSnackbarAppearsWithUnusableGroupId() {
        app.buttons["Cribbage"].tap()
        
        let newGameBtn = app.buttons["Join Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 1), "Join Game Button should appear")
        newGameBtn.tap()
        
        let groupIdTextField = app.textFields["Group ID"]
        XCTAssertTrue(groupIdTextField.waitForExistence(timeout: 1), "Group ID Text Field should appear")
        groupIdTextField.tap()
        app.typeText("10075")

        let snackbarDescription = app.staticTexts["Group ID is not valid!"]
        XCTAssertTrue(snackbarDescription.waitForExistence(timeout: 1), "Warning snackbar should be present")
    }
}

final class LoadingScreenUITests: XCTestCase {
    
    private var playerOne: XCUIApplication!
    private var playerTwo: XCUIApplication!
    private var playerThree: XCUIApplication!
    private var playerFour: XCUIApplication!
    private var playerFive: XCUIApplication!
    private var playerSix: XCUIApplication!
    private var id: Int!
    
    override func setUp() {
        continueAfterFailure = false
        
        // Player One
        playerOne = XCUIApplication(bundleIdentifier: "dan424gg.Cards")
        playerOne.launchArguments = ["-testing"]
        playerOne.launch()

        // Player Two
        playerTwo = XCUIApplication(bundleIdentifier: "dan424gg.Cards2")
        playerTwo.launchArguments = ["-testing"]
        playerTwo.launch()

        // Player Three
        playerThree = XCUIApplication(bundleIdentifier: "dan424gg.Cards3")
        playerThree.launchArguments = ["-testing"]
        playerThree.launch()

        // Player Four
        playerFour = XCUIApplication(bundleIdentifier: "dan424gg.Cards4")
        playerFour.launchArguments = ["-testing"]
        playerFour.launch()

        // Player Five
        playerFive = XCUIApplication(bundleIdentifier: "dan424gg.Cards5")
        playerFive.launchArguments = ["-testing"]
        playerFive.launch()
        
        // Player Six
        playerSix = XCUIApplication(bundleIdentifier: "dan424gg.Cards6")
        playerSix.launchArguments = ["-testing"]
        playerSix.launch()

    }
    
    override func tearDown() {
        playerOne = nil
        playerTwo = nil
        playerThree = nil
        playerFour = nil
        playerFive = nil
        playerSix = nil
    }
    
    func testInitialLoadingScreen() {
        playerOne.buttons["Cribbage"].tap()
        
        let newGameBtn = playerOne.buttons["New Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 1), "New Game Button should appear")
        newGameBtn.tap()
        
        let fullNameTextField = playerOne.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 1), "Full Name Text Field should appear")
        fullNameTextField.tap()
        
        playerOne.typeText("Player One")
        let submitBtn = playerOne.buttons["Submit"]
        submitBtn.tap()
        
        XCTAssertTrue(playerOne.staticTexts["Hi Player One!"].waitForExistence(timeout: 0.5))
    }
    
    func testPlayersJoiningLoadingScreen() {
        playerOne.buttons["Cribbage"].tap()
        let newGameBtn = playerOne.buttons["New Game"]
        XCTAssertTrue(newGameBtn.waitForExistence(timeout: 2), "New Game Button should appear")
        newGameBtn.tap()
        
        var fullNameTextField = playerOne.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 2), "Full Name Text Field should appear")
        fullNameTextField.tap()
        
        playerOne.typeText("Player One")
        var submitBtn = playerOne.buttons["Submit"]
        submitBtn.tap()
        
        XCTAssertTrue(playerOne.staticTexts["Hi Player One!"].waitForExistence(timeout: 2))

        playerTwo.buttons["Cribbage"].tap()
        var joinGameBtn = playerTwo.buttons["Join Game"]
        XCTAssertTrue(joinGameBtn.waitForExistence(timeout: 2), "Join Game Button should appear")
        joinGameBtn.tap()
        
        var groupIdTextField = playerTwo.textFields["Group ID"]
        XCTAssertTrue(groupIdTextField.waitForExistence(timeout: 2), "Group ID Text Field should appear")
        groupIdTextField.tap()
        playerTwo.typeText("10076")
        
        fullNameTextField = playerTwo.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 2), "Player Two Full Name Text Field should appear")
        fullNameTextField.tap()
        
        playerTwo.typeText("Player Two")
        submitBtn = playerTwo.buttons["Submit"]
        submitBtn.tap()
        
        XCTAssertTrue(playerOne.staticTexts["Player Two"].waitForExistence(timeout: 2))
        XCTAssertTrue(playerTwo.staticTexts["Hi Player Two!"].waitForExistence(timeout: 2))
        
        playerThree.buttons["Cribbage"].tap()
        joinGameBtn = playerThree.buttons["Join Game"]
        XCTAssertTrue(joinGameBtn.waitForExistence(timeout: 2), "Join Game Button should appear")
        joinGameBtn.tap()
        
        groupIdTextField = playerThree.textFields["Group ID"]
        XCTAssertTrue(groupIdTextField.waitForExistence(timeout: 2), "Group ID Text Field should appear")
        groupIdTextField.tap()
        playerThree.typeText("10076")
        
        fullNameTextField = playerThree.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 2), "Player Three Full Name Text Field should appear")
        fullNameTextField.tap()
        
        playerThree.typeText("Player Three")
        submitBtn = playerThree.buttons["Submit"]
        submitBtn.tap()
        
        XCTAssertTrue(playerOne.staticTexts["Player Three"].waitForExistence(timeout: 2))
        XCTAssertTrue(playerThree.staticTexts["Hi Player Three!"].waitForExistence(timeout: 2))
        
        playerFour.buttons["Cribbage"].tap()
        joinGameBtn = playerFour.buttons["Join Game"]
        XCTAssertTrue(joinGameBtn.waitForExistence(timeout: 2), "Join Game Button should appear")
        joinGameBtn.tap()
        
        groupIdTextField = playerFour.textFields["Group ID"]
        XCTAssertTrue(groupIdTextField.waitForExistence(timeout: 2), "Group ID Text Field should appear")
        groupIdTextField.tap()
        playerFour.typeText("10076")
        
        fullNameTextField = playerFour.textFields["Full Name"]
        XCTAssertTrue(fullNameTextField.waitForExistence(timeout: 2), "Player Four Full Name Text Field should appear")
        fullNameTextField.tap()
        
        playerFour.typeText("Player Four")
        submitBtn = playerFour.buttons["Submit"]
        submitBtn.tap()
        
        XCTAssertTrue(playerOne.staticTexts["Player Four"].waitForExistence(timeout: 2))
        XCTAssertTrue(playerFour.staticTexts["Hi Player Four!"].waitForExistence(timeout: 2))
    }
}
