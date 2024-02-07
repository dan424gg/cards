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
        } while (await playerOne.checkValidId(id: "\(randId)"))
        
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        XCTAssert(playerOne.players.count == 1)
        XCTAssert(playerOne.teams.count == 1)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testJoinGameCollection() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        XCTAssert(playerTwo.players.count == 2)
        XCTAssert(playerTwo.teams.count == 2)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testPlayersListener() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssert(playerOne.players.count == 2, "check for duplicate current player FAILED")
        XCTAssert(playerOne.players.contains(where: { player in
            player.uid == playerTwo.playerState!.uid
        }))
        XCTAssert(playerTwo.players.contains(where: { player in
            player.uid == playerOne.playerState!.uid
        }))

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testTeamsListener() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
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
                
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testGameListener() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssertTrue(playerOne.gameState!.turn == playerTwo.gameState!.turn)
        
        await playerOne.updateGame(newState: ["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.turn == playerTwo.gameState!.turn)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testChangeTeam() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        print(randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        let oldColor = playerOne.teamState!.color
        await playerOne.changeTeam(newTeamNum: 2)

        XCTAssertTrue(playerOne.teamState!.team_num == 2)
        XCTAssertTrue(playerOne.playerState!.team_num == 2)
        XCTAssertFalse(playerOne.teams.contains(where: { $0.team_num == 1 }))
        XCTAssertTrue(playerOne.gameState!.colors_available.count == 5)
        XCTAssertTrue(playerOne.gameState!.colors_available.contains(where: { $0 == oldColor }))

        XCTAssertTrue(playerTwo.teams.count == 1)
        XCTAssertFalse(playerTwo.teams.contains(where: { $0.team_num == 1 }))
        
        await playerOne.changeTeam(newTeamNum: 1)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        XCTAssertTrue(playerOne.teamState!.team_num == 1)
        XCTAssertTrue(playerOne.playerState!.team_num == 1)
        XCTAssertTrue(playerOne.teams.contains(where: { $0.team_num == 1 }))
        XCTAssertTrue(playerOne.gameState!.colors_available.count == 4)
        XCTAssertFalse(playerOne.gameState!.colors_available.contains(where: { $0 == playerOne.teamState!.color }))

        XCTAssertTrue(playerTwo.teams.count == 2)
        XCTAssertTrue(playerTwo.teams.contains(where: { $0.team_num == 1 }))
        
        // flood changeTeam
        let playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        let playerFour = FirebaseHelper()
        await playerFour.joinGameCollection(fullName: "4", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerFive = FirebaseHelper()
        await playerFive.joinGameCollection(fullName: "5", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerSix = FirebaseHelper()
        await playerSix.joinGameCollection(fullName: "6", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        await playerOne.changeTeam(newTeamNum: 3)
        await playerTwo.changeTeam(newTeamNum: 3)
        await playerThree.changeTeam(newTeamNum: 2)
        await playerFour.changeTeam(newTeamNum: 1)
        await playerFive.changeTeam(newTeamNum: 2)
        await playerSix.changeTeam(newTeamNum: 1)
        
        XCTAssertTrue(playerOne.playerState!.team_num == 3)
        XCTAssertTrue(playerTwo.playerState!.team_num == 3)
        XCTAssertTrue(playerThree.playerState!.team_num == 2)
        XCTAssertTrue(playerFour.playerState!.team_num == 1)
        XCTAssertTrue(playerFive.playerState!.team_num == 2)
        XCTAssertTrue(playerSix.playerState!.team_num == 1)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdateGame() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
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
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdatePlayer() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // single variable tests
        await playerOne.updatePlayer(newState: ["is_ready": true])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.is_ready, "TESTUPDATEGAME: playerState wasn't updated locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.is_ready, "TESTUPDATEGAME: playerState wasn't updated in firebase!")
        
        // array variable tests
        // cardAction '.append' test
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0, 1, 2]], cardAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerOne.playerState!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't appended locally!")
        }
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't appended in firebase!")
        }
        
        await playerOne.updatePlayer(newState: ["cards_in_hand": [3]], cardAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand.contains(3), "TESTUPDATEPLAYER: single card: 3 wasn't removed locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand.contains(3), "TESTUPDATEPLAYER: single card: 3 wasn't removed in firebase!")

        // cardAction '.remove' test
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0, 1, 2, 3]], cardAction: .remove)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerOne.playerState!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't removed in firebase!")
        }
        
        // cardAction '.replace' test
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0, 1, 2, 3]], cardAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand == [0, 1, 2, 3], "TESTUPDATEPLAYER: cards weren't replaced locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand == [0, 1, 2, 3], "TESTUPDATEPLAYER: cards weren't replaced in firebase!")
        
        // modify other player's state (ONLY MEANT TO BE USED BY LEAD)
        await playerOne.updatePlayer(newState: ["cards_in_hand": [2, 3]], uid: playerTwo.playerState!.uid, cardAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand == [2, 3], "TESTUPDATEPLAYER: cards weren't replaced locally!")
        XCTAssertTrue(playerOne.players.first(where: { player in player.name == "2"})!.cards_in_hand == [2, 3], "TESTUPDATEPLAYER: cards weren't replaced in firebase!")

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdateTeam() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.updateTeam(newState: ["points": 50])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.teamState!.points == 50, "TESTUPDATETEAM: teamState wasn't updated locally!")
        XCTAssertTrue(playerTwo.teams.first(where: { team in team.team_num == 1})!.points == 50, "TESTUPDATETEAM: teamState wasn't updated in firebase!")
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testShuffleAndDeal() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // test that players have correct number of cards in hands
        await playerOne.updateGame(newState: ["dealer": 0])
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        XCTAssertNotEqual(playerOne.gameState!.cards, playerOne.gameState!.cards.sorted())
        XCTAssertTrue(playerOne.playerState!.cards_in_hand.count == 6)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand.count == 6)
        XCTAssertTrue(playerOne.gameState!.starter_card != -1)
        XCTAssertFalse(playerOne.gameState!.cards.contains(playerOne.gameState!.starter_card))
        
        // add another player (3)
        let playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerThree.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerOne.gameState!.crib.count == 1)
        
        // add another player (4)
        let playerFour = FirebaseHelper()
        await playerFour.joinGameCollection(fullName: "4", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerThree.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerFour.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerOne.gameState!.crib.count == 0)
        
        // add another two players (6)
        let playerFive = FirebaseHelper()
        await playerFive.joinGameCollection(fullName: "5", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        let playerSix = FirebaseHelper()
        await playerSix.joinGameCollection(fullName: "6", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand.count == 4)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerThree.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerFour.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerFive.playerState!.cards_in_hand.count == 5)
        XCTAssertTrue(playerSix.playerState!.cards_in_hand.count == 4)
        XCTAssertTrue(playerOne.gameState!.cards.count == 23)
        XCTAssertTrue(playerOne.gameState!.crib.count == 0)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testCheckForRun() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        await playerOne.updateGame(newState: ["play_cards": [2, 4, 16]], action: .replace)
        XCTAssertEqual(playerOne.checkForRun(), 3)
        
        playerOne.gameState!.play_cards = [0, 1, 51]
        XCTAssert(playerOne.checkForRun() == 0)
        
        playerOne.gameState!.play_cards = [11, 12, 13]
        XCTAssert(playerOne.checkForRun() == 0)
        
        playerOne.gameState!.play_cards = [2, 0, 1, 3]
        XCTAssert(playerOne.checkForRun() == 4)
        
        playerOne.gameState!.play_cards = [13, 11, 12]
        XCTAssert(playerOne.checkForRun() == 0)
        
        playerOne.gameState!.play_cards = [11, 12]
        XCTAssert(playerOne.checkForRun() == 0)
        
        playerOne.gameState!.play_cards = [0, 12]
        XCTAssert(playerOne.checkForRun() == 0)

        playerOne.gameState!.play_cards = [2, 1, 39]
        XCTAssertEqual(playerOne.checkForRun(), 3)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testManagePlayTurn() async {
        var result = 0
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        var dummyCallout: [String] = []
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0,1,2,3,4,5]], cardAction: .replace)
        await playerTwo.updatePlayer(newState: ["cards_in_hand": [0,1,2,3,4,5]], cardAction: .replace)
        
        // test for sum of 15
        await playerOne.updateGame(newState: ["running_sum": 5])
        await playerOne.updateGame(newState: ["play_cards": [] as! [Int]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 11, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 2)
        
        // test for not going over 31
        await playerOne.updateGame(newState: ["running_sum": 22])
        await playerOne.updateGame(newState: ["play_cards": [] as! [Int]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 11, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, -1)
        XCTAssertEqual(playerOne.gameState!.running_sum, 22)
        
        // test for sum of 31
        await playerOne.updateGame(newState: ["running_sum": 21])
        await playerOne.updateGame(newState: ["play_cards": [] as! [Int]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 11, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 2)
        
        // test for pair
        await playerOne.updateGame(newState: ["play_cards": [0] as! [Int]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 26, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 2)
        
        // test for pair royal
        await playerOne.updateGame(newState: ["play_cards": [0, 13] as! [Int]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 26, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 6)
        
        // test for double pair royal
        await playerOne.updateGame(newState: ["play_cards": [0, 13, 39] as! [Int]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 26, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 12)
        
        // test for sequence of 3
        await playerOne.updateGame(newState: ["running_sum": 0])
        await playerOne.updateGame(newState: ["play_cards": [2, 4]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 16, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 3)
        
        // test for sequence of 4
        await playerOne.updateGame(newState: ["running_sum": 0])
        await playerOne.updateGame(newState: ["play_cards": [0, 2, 3]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 1, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 4)
        
        // test for sequence of 5
        await playerOne.updateGame(newState: ["running_sum": 0])
        await playerOne.updateGame(newState: ["play_cards": [0, 2, 3, 4]], action: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 1, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 5)
        
        // test when last in a go
        await playerOne.updateGame(newState: ["num_go": 1])
        result = await playerOne.managePlayTurn(cardInPlay: nil, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 1)
        
        // test when first or in the middle of a go
        await playerOne.updateGame(newState: ["num_go": 0])
        result = await playerOne.managePlayTurn(cardInPlay: nil, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 0)
        
        // test for num_go going back to 0 with valid card
        XCTAssertEqual(playerOne.gameState!.num_go, 1)
        _ = await playerOne.managePlayTurn(cardInPlay: 0, pointsCallOut: &dummyCallout)
        XCTAssertEqual(playerOne.gameState!.num_go, 0)
        
        // test for last card point
        await playerOne.updateGame(newState: ["running_sum": 0])
        await playerOne.updateGame(newState: ["play_cards": [] as! [Int]], action: .replace)
        await playerOne.updatePlayer(newState: ["cards_in_hand": [0]], cardAction: .replace)
        await playerTwo.updatePlayer(newState: ["cards_in_hand": [] as! [Int]], cardAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 0, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 1)

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testCheckForPoints() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        playerOne.playerState!.cards_in_hand = [9,10,11,12]
        playerOne.gameState!.running_sum = 21
        XCTAssertTrue(playerOne.checkHandForPoints())
        
        playerOne.playerState!.cards_in_hand = [9,10,11,12]
        playerOne.gameState!.running_sum = 30
        XCTAssertFalse(playerOne.checkHandForPoints())
        
        playerOne.playerState!.cards_in_hand = [10,11,12,0]
        playerOne.gameState!.running_sum = 30
        XCTAssertTrue(playerOne.checkHandForPoints())
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdatePlayerNums() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // manual checks
        await playerOne.updatePlayer(newState: ["player_num": 4])
        await playerTwo.updatePlayer(newState: ["player_num": 7])
        
        await playerOne.updatePlayerNums()

        XCTAssertTrue(playerOne.playerState!.player_num == 0)
        XCTAssertTrue(playerTwo.playerState!.player_num == 1)
        
        // game simulation check
        let playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerTwo.changeTeam(newTeamNum: 3)
        await playerThree.changeTeam(newTeamNum: 2)
        
        await playerOne.updatePlayerNums()
        
        XCTAssertTrue(playerTwo.playerState!.player_num == 2)
        XCTAssertTrue(playerThree.playerState!.player_num == 1)
        
        // more players
        let playerFour = FirebaseHelper()
        await playerFour.joinGameCollection(fullName: "4", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerFive = FirebaseHelper()
        await playerFive.joinGameCollection(fullName: "5", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerSix = FirebaseHelper()
        await playerSix.joinGameCollection(fullName: "6", id: "\(randId)", gameName: "Cribbage")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        await playerOne.changeTeam(newTeamNum: 3)
        await playerTwo.changeTeam(newTeamNum: 3)
        await playerThree.changeTeam(newTeamNum: 2)
        await playerFour.changeTeam(newTeamNum: 1)
        await playerFive.changeTeam(newTeamNum: 2)
        await playerSix.changeTeam(newTeamNum: 1)
        
        await playerOne.updatePlayerNums()
        
        XCTAssertTrue(playerOne.playerState!.player_num == 2)
        XCTAssertTrue(playerTwo.playerState!.player_num == 5)
        XCTAssertTrue(playerThree.playerState!.player_num == 1)
        XCTAssertTrue(playerFour.playerState!.player_num == 0)
        XCTAssertTrue(playerFive.playerState!.player_num == 4)
        XCTAssertTrue(playerSix.playerState!.player_num == 3)
        
        print(playerOne.players.sorted(by: { $0.player_num < $1.player_num }))
        
        await playerOne.deleteGameCollection(id: randId)
    }
}


