//
//  FirebaseTests.swift
//  CardsTests
//
//  Created by Daniel Wells on 11/28/23.
//

import XCTest
import SwiftUI

import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

@testable import Cards

final class FirebaseHelperTests: XCTestCase {
    @MainActor func testStartGameCollection() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        XCTAssert(playerOne.players.count == 1)
        XCTAssert(playerOne.teams.count == 1)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testJoinGameCollection() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)

        XCTAssert(playerTwo.players.count == 2)
        XCTAssert(playerTwo.teams.count == 2)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testPlayersListener() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        XCTAssert(playerOne.players.count == 2, "check for duplicate current player FAILED")
        XCTAssert(playerOne.players.contains(where: { player in
            player.uid == playerTwo.playerState!.uid
        }))
                
        let updatedPlayer = playerTwo.players.first(where: { player in
            player.uid == playerOne.playerState!.uid!
        })
                
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testTeamsListener() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        XCTAssert(playerOne.teams.count == 2)
        XCTAssert(playerOne.teams.contains(where: { team in
            team.team_num == playerTwo.teamState!.team_num
        }))
                
        let updatedTeam = playerTwo.teams.first(where: { team in
            team.team_num == playerOne.teamState!.team_num
        })
        
        XCTAssertTrue(updatedTeam!.has_crib)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testGameListener() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        XCTAssertTrue(playerOne.gameState!.turn == playerTwo.gameState!.turn)
        
        await playerOne.updateGame(newState: ["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        XCTAssertTrue(playerOne.gameState!.turn == playerTwo.gameState!.turn)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    // TO-DO
    @MainActor func testChangeTeam() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
    }
    
    @MainActor func testUpdateGame() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        playerOne.teamState!.has_crib = true
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        // single variable tests
        await playerOne.updateGame(newState: ["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        XCTAssert(playerOne.gameState!.turn == 1, "TESTUPDATEGAME: gameState wasn't updated locally!")
        XCTAssert(playerTwo.gameState!.turn == 1, "TESTUPDATEGAME: gameState wasn't updated in firebase!")
        
        // array variable tests
        // cardAction '.remove' test
        await playerOne.updateGame(newState: ["cards": [0, 1, 2, 3]], cardAction: .remove)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerOne.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerTwo.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed in firebase!")
        }
        
        // cardAction '.append' test
        await playerOne.updateGame(newState: ["cards": [0, 1, 2]], cardAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerOne.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerTwo.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed in firebase!")
        }
        
        await playerOne.updateGame(newState: ["cards": [3]], cardAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.cards.contains(3), "TESTUPDATEGAME: single card: 3 wasn't removed locally!")
        XCTAssertTrue(playerTwo.gameState!.cards.contains(3), "TESTUPDATEGAME: single card: 3 wasn't removed in firebase!")

        
        // cardAction '.replace' test
        await playerOne.updateGame(newState: ["cards": [0, 1, 2, 3]], cardAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.cards == [0, 1, 2, 3], "TESTUPDATEGAME: cards weren't replaced locally!")
        XCTAssertTrue(playerTwo.gameState!.cards == [0, 1, 2, 3], "TESTUPDATEGAME: cards weren't replaced in firebase!")
        
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdateCards() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        playerOne.teamState!.has_crib = true
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
//        XCTAssert(playerOne.playerState?.cards_in_hand == [])
//        XCTAssert(playerOne.teamState?.crib == [])
//        
//        let cards = Array(0...4)
//        playerOne.updateCards(cards: cards)
//        XCTAssert(playerOne.playerState?.cards_in_hand == cards, "cards were not updated in player's cards_in_hand!")
//        
//        playerOne.updateCards(cards: cards, crib: true)
//        XCTAssert(playerOne.teamState?.crib == cards, "cards were not updated in team's crib!")
//        
//        playerOne.updateCards(cards: cards, uid: playerTwo.playerState!.uid)
//        XCTAssert(playerTwo.playerState!.cards_in_hand == cards, "cards were not updated in playerTwo's cards_in_hand!")
        
        playerOne.deleteGameCollection(id: randId)
    }
}


