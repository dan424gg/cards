//
//  CardsTests.swift
//  CardsTests
//
//  Created by Daniel Wells on 10/11/23.
//

import XCTest
import SwiftUI

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

@testable import Cards

final class FirebaseTests: XCTestCase {
    @MainActor func testTwoPlayerDeal() async {
        var playerOne = FirebaseHelper()
        playerOne.deleteGameCollection(id: 123)
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: 123)
        
        var playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: 123, gameName: "Cribbage")
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.dealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerOne.gameInfo!.cards.count == 46)
        XCTAssert(playerOne.playerInfo!.cards_in_hand!.count == 6)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        cardsInHand_Binding = []
        await playerTwo.dealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerTwo.gameInfo!.cards.count == 40)
        XCTAssert(playerTwo.playerInfo!.cards_in_hand!.count == 6)
    }
    
    @MainActor func testThreePlayerDeal() async {
        var playerOne = FirebaseHelper()
        playerOne.deleteGameCollection(id: 123)
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: 123)
        playerOne.updatePlayer(newState: ["is_dealer": true])
        playerOne.updateTeam(newState: ["has_crib": true])
        
        var playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: 123, gameName: "Cribbage")
        
        var playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: 123, gameName: "Cribbage")
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.dealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        XCTAssert(playerOne.teamInfo!.crib.count == 1)
    }
    
    @MainActor func testFourPlayerDeal() async {
        var playerOne = FirebaseHelper()
        playerOne.deleteGameCollection(id: 123)
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: 123)
        
        var playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: 123, gameName: "Cribbage")
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.dealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerOne.gameInfo!.cards.count == 46)
        XCTAssert(playerOne.playerInfo!.cards_in_hand!.count == 6)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        cardsInHand_Binding = []
        await playerTwo.dealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerTwo.gameInfo!.cards.count == 40)
        XCTAssert(playerTwo.playerInfo!.cards_in_hand!.count == 6)
    }
    
    @MainActor func testSixPlayerDeal() async {
        var playerOne = FirebaseHelper()
        playerOne.deleteGameCollection(id: 123)
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: 123)
        
        var playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: 123, gameName: "Cribbage")
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.dealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerOne.gameInfo!.cards.count == 46)
        XCTAssert(playerOne.playerInfo!.cards_in_hand!.count == 6)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        cardsInHand_Binding = []
        await playerTwo.dealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerTwo.gameInfo!.cards.count == 40)
        XCTAssert(playerTwo.playerInfo!.cards_in_hand!.count == 6)
    }
}

final class LoadingScreenTests: XCTestCase {
    func testEqualNumOfPlayersOnTeam() {
        var playerList: [PlayerInformation] = []
        
        playerList.append(PlayerInformation(uid: "1", team_num: 1))
        XCTAssertFalse(equalNumOfPlayersOnTeam(players: playerList))

        playerList.append(PlayerInformation(uid: "2", team_num: 1))
        XCTAssertTrue(equalNumOfPlayersOnTeam(players: playerList))

        playerList.append(PlayerInformation(uid: "3", team_num: 2))
        XCTAssertFalse(equalNumOfPlayersOnTeam(players: playerList))
        
        playerList.append(PlayerInformation(uid: "4", team_num: 2))
        XCTAssertTrue(equalNumOfPlayersOnTeam(players: playerList))
    }
}

final class PlayerListenerListTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddPlayer() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = ListenerList()
        
        list.addListener(uid: "0", listenerObject: listener)
        list.addListener(uid: "1", listenerObject: listener)
        list.addListener(uid: "2", listenerObject: listener)
        list.addListener(uid: "3", listenerObject: listener)
        list.addListener(uid: "4", listenerObject: listener)
        
        for i in 0...4 {
            XCTAssertTrue(list.contains(uid: "\(i)"), "couldn't find uid: \(i)")
        }
    }
    
    func testRemovePlayer() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = ListenerList()
        
        for i in 0...4 {
            list.addListener(uid: "\(i)", listenerObject: listener)
        }
        
        _ = list.removeListener(uid: "\(3)")
        XCTAssertFalse(list.contains(uid: "\(3)"), "removePlayerListener didn't remove uid: 3")
        _ = list.removeListener(uid: "\(0)")
        XCTAssertFalse(list.contains(uid: "\(0)"), "removePlayerListener didn't remove uid: 3")
        _ = list.removeListener(uid: "\(4)")
        XCTAssertFalse(list.contains(uid: "\(4)"), "removePlayerListener didn't remove uid: 3")
    }
    
    func testPop() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = ListenerList()
        
        for i in 0...4 {
            list.addListener(uid: "\(i)", listenerObject: listener)
        }
        
        let popped = list.pop()
        XCTAssertTrue(list.first()!.uid != popped.uid)
        XCTAssertFalse(list.contains(uid: popped.uid!))
    }
    
    func testIsEmpty() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = ListenerList()
        
        XCTAssertTrue(list.isEmpty())
        
        for i in 0...4 {
            list.addListener(uid: "\(i)", listenerObject: listener)
        }
        
        XCTAssertFalse(list.isEmpty())
    }
    
    func testRemoveAllPlayerListeners() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = ListenerList()
        
        for i in 0...4 {
            list.addListener(uid: "\(i)", listenerObject: listener)
        }
        
        list.removeAllListeners()
        
        XCTAssertTrue(list.isEmpty())
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
