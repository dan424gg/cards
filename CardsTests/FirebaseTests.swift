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
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

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
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssert(playerOne.players.count == 2, "check for duplicate current player FAILED")
        XCTAssert(playerOne.players.contains(where: { player in
            player.uid == playerTwo.playerState!.uid
        }))
        XCTAssert(playerTwo.players.contains(where: { player in
            player.uid == playerOne.playerState!.uid
        }))

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
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssert(playerOne.teams.count == 2)
        XCTAssert(playerOne.teams.contains(where: { team in
            team.team_num == playerTwo.teamState!.team_num
        }))
        XCTAssert(playerTwo.teams.contains(where: { team in
            team.team_num == playerOne.teamState!.team_num
        }))
        
        // test .modified
        await playerOne.updateTeam(newState: ["points": 50])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerTwo.teams.first(where: { team in team.team_num == 1 })?.points == 50)
                
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
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssertTrue(playerOne.gameState!.turn == playerTwo.gameState!.turn)
        
        await playerOne.updateGame(newState: ["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
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
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
    }
    
    @MainActor func testUpdateGame() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // single variable tests
        await playerOne.updateGame(newState: ["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssert(playerOne.gameState!.turn == 1, "TESTUPDATEGAME: gameState wasn't updated locally!")
        XCTAssert(playerTwo.gameState!.turn == 1, "TESTUPDATEGAME: gameState wasn't updated in firebase!")
        
        // array variable tests
        // cardAction '.remove' test
        await playerOne.updateGame(newState: ["cards": [0, 1, 2, 3]], action: .remove)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerOne.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerTwo.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed in firebase!")
        }
        
        // cardAction '.append' test
        await playerOne.updateGame(newState: ["cards": [0, 1, 2]], action: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerOne.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerTwo.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed in firebase!")
        }
        
        await playerOne.updateGame(newState: ["cards": [3]], action: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.cards.contains(3), "TESTUPDATEGAME: single card: 3 wasn't removed locally!")
        XCTAssertTrue(playerTwo.gameState!.cards.contains(3), "TESTUPDATEGAME: single card: 3 wasn't removed in firebase!")
        
        // cardAction '.replace' test
        await playerOne.updateGame(newState: ["cards": [0, 1, 2, 3]], action: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.cards == [0, 1, 2, 3], "TESTUPDATEGAME: cards weren't replaced locally!")
        XCTAssertTrue(playerTwo.gameState!.cards == [0, 1, 2, 3], "TESTUPDATEGAME: cards weren't replaced in firebase!")
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdatePlayer() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // single variable tests
        await playerOne.updatePlayer(newState: ["is_ready": true])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.is_ready!, "TESTUPDATEGAME: playerState wasn't updated locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.is_ready!, "TESTUPDATEGAME: playerState wasn't updated in firebase!")
        
        // array variable tests
        // cardAction '.append' test
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0, 1, 2]], cardAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerOne.playerState!.cards_in_hand!.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't appended locally!")
        }
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand!.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't appended in firebase!")
        }
        
        await playerOne.updatePlayer(newState: ["cards_in_hand": [3]], cardAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand!.contains(3), "TESTUPDATEPLAYER: single card: 3 wasn't removed locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand!.contains(3), "TESTUPDATEPLAYER: single card: 3 wasn't removed in firebase!")

        // cardAction '.remove' test
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0, 1, 2, 3]], cardAction: .remove)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerOne.playerState!.cards_in_hand!.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand!.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't removed in firebase!")
        }
        
        // cardAction '.replace' test
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0, 1, 2, 3]], cardAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand! == [0, 1, 2, 3], "TESTUPDATEPLAYER: cards weren't replaced locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand! == [0, 1, 2, 3], "TESTUPDATEPLAYER: cards weren't replaced in firebase!")
        
        // modify other player's state (ONLY MEANT TO BE USED BY LEAD)
        await playerOne.updatePlayer(newState: ["cards_in_hand": [2, 3]], uid: playerTwo.playerState!.uid, cardAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand! == [2, 3], "TESTUPDATEPLAYER: cards weren't replaced locally!")
        XCTAssertTrue(playerOne.players.first(where: { player in player.name == "2"})!.cards_in_hand! == [2, 3], "TESTUPDATEPLAYER: cards weren't replaced in firebase!")

        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdateTeam() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.updateTeam(newState: ["points": 50])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.teamState!.points == 50, "TESTUPDATETEAM: teamState wasn't updated locally!")
        XCTAssertTrue(playerTwo.teams.first(where: { team in team.team_num == 1})!.points == 50, "TESTUPDATETEAM: teamState wasn't updated in firebase!")
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testShuffleAndDeal() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // test that players have correct number of cards in hands
        await playerOne.updateGame(newState: ["dealer": 0])
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        XCTAssertNotEqual(playerOne.gameState!.cards, playerOne.gameState!.cards.sorted())
        XCTAssertTrue(playerOne.playerState!.cards_in_hand!.count == 6)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand!.count == 6)
        XCTAssertTrue(playerOne.gameState!.starter_card != -1)
        XCTAssertFalse(playerOne.gameState!.cards.contains(playerOne.gameState!.starter_card))
        
        // add another player (3)
        let playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerThree.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerOne.gameState!.crib.count == 1)
        
        // add another player (4)
        let playerFour = FirebaseHelper()
        await playerFour.joinGameCollection(fullName: "4", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerThree.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerFour.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerOne.gameState!.crib.count == 0)
        
        // add another two players (6)
        let playerFive = FirebaseHelper()
        await playerFive.joinGameCollection(fullName: "5", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        let playerSix = FirebaseHelper()
        await playerSix.joinGameCollection(fullName: "6", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand!.count == 4)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerThree.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerFour.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerFive.playerState!.cards_in_hand!.count == 5)
        XCTAssertTrue(playerSix.playerState!.cards_in_hand!.count == 4)
        XCTAssertTrue(playerOne.gameState!.cards.count == 23)
        XCTAssertTrue(playerOne.gameState!.crib.count == 0)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testCheckForRun() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        playerOne.gameState!.play_cards = [0, 1]
        XCTAssert(playerOne.checkForRun(cardInPlay: 2) == 3)
        
        playerOne.gameState!.play_cards = [0, 1]
        XCTAssert(playerOne.checkForRun(cardInPlay: 51) == 0)
        
        playerOne.gameState!.play_cards = [0, 1]
        XCTAssert(playerOne.checkForRun(cardInPlay: 51) == 0)
        
        playerOne.gameState!.play_cards = [11, 12]
        XCTAssert(playerOne.checkForRun(cardInPlay: 13) == 0)
        
        playerOne.gameState!.play_cards = [2, 0, 1]
        XCTAssert(playerOne.checkForRun(cardInPlay: 3) == 4)
        
        playerOne.gameState!.play_cards = [13, 11]
        XCTAssert(playerOne.checkForRun(cardInPlay: 12) == 0)
        
        playerOne.gameState!.play_cards = [11]
        XCTAssert(playerOne.checkForRun(cardInPlay: 12) == 0)
        
        playerOne.gameState!.play_cards = [0]
        XCTAssert(playerOne.checkForRun(cardInPlay: 12) == 0)

        playerOne.gameState!.play_cards = [2, 1]
        XCTAssertEqual(playerOne.checkForRun(cardInPlay: 39), 3)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testCheckForPoints() async {
        var result = 0
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // test for sum of 15
        playerOne.gameState!.running_sum = 5
        result = await playerOne.checkForPoints(cardInPlay: 11)
        XCTAssertEqual(result, 2)
        
        // test for sum of 31
        playerOne.gameState!.running_sum = 21
        result = await playerOne.checkForPoints(cardInPlay: 11)
        XCTAssertEqual(result, 2)
        
        // test for pair
        playerOne.gameState!.play_cards = [0]
        result = await playerOne.checkForPoints(cardInPlay: 26)
        XCTAssertEqual(result, 2)
        
        // test for pair royal
        playerOne.gameState!.play_cards = [0, 13]
        result = await playerOne.checkForPoints(cardInPlay: 26)
        XCTAssertEqual(result, 6)
        
        // test for double pair royal
        playerOne.gameState!.play_cards = [0, 13, 39]
        result = await playerOne.checkForPoints(cardInPlay: 26)
        XCTAssertEqual(result, 12)
        
        // test for sequence of 3
        playerOne.gameState!.play_cards = [0, 2]
        result = await playerOne.checkForPoints(cardInPlay: 1)
        XCTAssertEqual(result, 3)
        
        // test for sequence of 4
        playerOne.gameState!.play_cards = [0, 2, 3]
        result = await playerOne.checkForPoints(cardInPlay: 1)
        XCTAssertEqual(result, 4)
        
        // test for sequence
        playerOne.gameState!.play_cards = [0, 2, 4, 3]
        result = await playerOne.checkForPoints(cardInPlay: 1)
        XCTAssertEqual(result, 5)
        
        // test when last in a go
        playerOne.gameState!.num_go = 1
        result = await playerOne.checkForPoints()
        XCTAssertEqual(result, 1)
        
        // test when first or in the middle of a go
        playerOne.gameState!.num_go = 0
        result = await playerOne.checkForPoints()
        XCTAssertEqual(result, 0)

        playerOne.deleteGameCollection(id: randId)
    }
}


