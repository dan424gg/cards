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

final class LoadingScreenTests: XCTestCase {
    @MainActor func testPlayerThreeChangesTeamWhenFourthJoins() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1",  testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        let playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        let playerFour = FirebaseHelper()
        await playerFour.joinGameCollection(fullName: "4", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.5)
        
        XCTAssertTrue(playerThree.teamState!.team_num == 1)
        XCTAssertTrue(playerFour.teamState!.team_num == 2)
        XCTAssertFalse(playerFour.teams.contains(where: { $0.team_num == 3 }))
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testEqualNumOfPlayersOnTeam() async {
        let firebaseHelper = FirebaseHelper()
//        var playerList: [PlayerState] = []
        
        firebaseHelper.playerState = PlayerState(uid: "1", team_num: 1)
        XCTAssertFalse(firebaseHelper.equalNumOfPlayersOnTeam())

        firebaseHelper.players.append(PlayerState(uid: "2", team_num: 2))
        XCTAssertTrue(firebaseHelper.equalNumOfPlayersOnTeam())

        firebaseHelper.players.append(PlayerState(uid: "3", team_num: 1))
        XCTAssertFalse(firebaseHelper.equalNumOfPlayersOnTeam())
        
        firebaseHelper.players.append(PlayerState(uid: "4", team_num: 2))
        XCTAssertTrue(firebaseHelper.equalNumOfPlayersOnTeam())
        
        firebaseHelper.players.append(PlayerState(uid: "5", team_num: 3))
        XCTAssertFalse(firebaseHelper.equalNumOfPlayersOnTeam())
        
        firebaseHelper.players.append(PlayerState(uid: "6", team_num: 3))
        XCTAssertTrue(firebaseHelper.equalNumOfPlayersOnTeam())
    }
    
    func testCardItemOperators() {
        var arr = [1, 3, 5, 2, 4]
        XCTAssertEqual(arr.sorted(by: { CardItem(id: $0) < CardItem(id: $1) }), [1,2,3,4,5])
        
//     values: A,  2,  A,  2,  A, 4
        arr = [0, 14, 13, 27, 26, 4]
        XCTAssertEqual(arr.sorted(by: { CardItem(id: $0) < CardItem(id: $1) }), [0,13,26,14,27,4]) // asc
        
        arr = [0, 14, 13, 27, 26, 4]
        XCTAssertEqual(arr.sorted(by: { CardItem(id: $0) <= CardItem(id: $1) }), [26,13,0,27,14,4]) // asc (desc)
        
        arr = [0, 14, 13, 27, 26, 4]
        XCTAssertEqual(arr.sorted(by: { CardItem(id: $0) > CardItem(id: $1) }), [4,14,27,0,13,26]) // desc (asc)
        
        arr = [0, 14, 13, 27, 26, 4]
        XCTAssertEqual(arr.sorted(by: { CardItem(id: $0) >= CardItem(id: $1) }), [4,27,14,26,13,0]) // desc
    }
}

final class ListenerListTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddPlayer() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = LinkedList()
        
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
        let list = LinkedList()
        
        for i in 0...3 {
            list.addListener(uid: "\(i)", listenerObject: listener)
        }
        
        XCTAssertFalse(list.removeListener(uid: "\(5)"), "uid: 5 doesn't exist")
        _ = list.removeListener(uid: "\(3)")
        XCTAssertFalse(list.contains(uid: "\(3)"), "removePlayerListener didn't remove uid: 3")
        _ = list.removeListener(uid: "\(0)")
        XCTAssertFalse(list.contains(uid: "\(0)"), "removePlayerListener didn't remove uid: 0")
        _ = list.removeListener(uid: "\(2)")
        XCTAssertFalse(list.contains(uid: "\(2)"), "removePlayerListener didn't remove uid: 2")
        _ = list.removeListener(uid: "\(1)")
        XCTAssertFalse(list.contains(uid: "\(1)"), "removePlayerListener didn't remove uid: 1")
        XCTAssertFalse(list.removeListener(uid: "\(1)"), "uid: 1 doesn't exist")
    }
    
    func testPop() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = LinkedList()
        
        for i in 0...4 {
            list.addListener(uid: "\(i)", listenerObject: listener)
        }
        
        let popped = list.pop()
        XCTAssertTrue(list.first()!.uid != popped.uid)
        XCTAssertFalse(list.contains(uid: popped.uid!))
    }
    
    func testIsEmpty() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = LinkedList()
        
        XCTAssertTrue(list.isEmpty())
        
        for i in 0...4 {
            list.addListener(uid: "\(i)", listenerObject: listener)
        }
        
        XCTAssertFalse(list.isEmpty())
    }
    
    func testRemoveAllPlayerListeners() {
        let listener = Firestore.firestore().collection("games").addSnapshotListener{_,_ in }
        let list = LinkedList()
        
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
