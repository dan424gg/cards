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

@testable import CardsPlayground

final class GameHelperTests: XCTestCase {
    @MainActor func testStartGameCollection() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertEqual(playerOne.gameState!.num_players, 1)
        XCTAssertEqual(playerOne.teams.count, 1)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testJoinGameCollection() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        // test normal join
        XCTAssert(playerTwo.gameState!.num_players == 2)
        XCTAssert(playerTwo.teams.count == 2)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testPlayersListener() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssert(playerOne.gameState!.num_players == 2, "check for duplicate current player FAILED")
        XCTAssert(playerOne.players.contains(where: { player in
            player.uid == playerTwo.playerState!.uid
        }))
        XCTAssert(playerTwo.players.contains(where: { player in
            player.uid == playerOne.playerState!.uid
        }))

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testTeamsListener() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssert(playerOne.teams.count == 2)
        XCTAssert(playerOne.teams.contains(where: { team in
            team.team_num == playerTwo.teamState!.team_num
        }))
        XCTAssert(playerTwo.teams.contains(where: { team in
            team.team_num == playerOne.teamState!.team_num
        }))
        
        // test .modified
        await playerOne.updateTeam(["points": 50])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerTwo.teams.first(where: { team in team.team_num == 1 })?.points == 50)
                
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testGameListener() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        XCTAssertTrue(playerOne.gameState!.turn == playerTwo.gameState!.turn)
        
        await playerOne.updateGame(["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.turn == playerTwo.gameState!.turn)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testChangeTeam() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
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
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.5)

        XCTAssertTrue(playerOne.teamState!.team_num == 1)
        XCTAssertTrue(playerOne.playerState!.team_num == 1)
        XCTAssertTrue(playerOne.teams.contains(where: { $0.team_num == 1 }))
        XCTAssertEqual(playerOne.gameState!.colors_available.count, 4)
        XCTAssertFalse(playerOne.gameState!.colors_available.contains(where: { $0 == playerOne.teamState!.color }))

        XCTAssertTrue(playerTwo.teams.count == 2)
        XCTAssertTrue(playerTwo.teams.contains(where: { $0.team_num == 1 }))
        
        // flood changeTeam
        let playerThree = GameHelper()
        await playerThree.joinGameCollection(fullName: "3", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        let playerFour = GameHelper()
        await playerFour.joinGameCollection(fullName: "4", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerFive = GameHelper()
        await playerFive.joinGameCollection(fullName: "5", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerSix = GameHelper()
        await playerSix.joinGameCollection(fullName: "6", id: "\(randId)")
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
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // single variable tests
        await playerOne.updateGame(["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssert(playerOne.gameState!.turn == 1, "TESTUPDATEGAME: gameState wasn't updated locally!")
        XCTAssert(playerTwo.gameState!.turn == 1, "TESTUPDATEGAME: gameState wasn't updated in firebase!")
        
        // array variable tests
        // cardAction '.remove' test
        await playerOne.updateGame(["cards": [0, 1, 2, 3]], arrayAction: .remove)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerOne.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerTwo.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed in firebase!")
        }
        
        // cardAction '.append' test
        await playerOne.updateGame(["cards": [0, 1, 2]], arrayAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerOne.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerTwo.gameState!.cards.contains(card), "TESTUPDATEGAME: card: \(card) wasn't removed in firebase!")
        }
        
        await playerOne.updateGame(["cards": [3]], arrayAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.cards.contains(3), "TESTUPDATEGAME: single card: 3 wasn't removed locally!")
        XCTAssertTrue(playerTwo.gameState!.cards.contains(3), "TESTUPDATEGAME: single card: 3 wasn't removed in firebase!")
        
        // cardAction '.replace' test
        await playerOne.updateGame(["cards": [0, 1, 2, 3]], arrayAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.gameState!.cards == [0, 1, 2, 3], "TESTUPDATEGAME: cards weren't replaced locally!")
        XCTAssertTrue(playerTwo.gameState!.cards == [0, 1, 2, 3], "TESTUPDATEGAME: cards weren't replaced in firebase!")
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdatePlayer() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // single variable tests
        await playerOne.updatePlayer(["is_ready": true])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.is_ready, "TESTUPDATEGAME: playerState wasn't updated locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.is_ready, "TESTUPDATEGAME: playerState wasn't updated in firebase!")
        
        // array variable tests
        // cardAction '.append' test
        await playerOne.updatePlayer(["cards_in_hand": [0, 1, 2]], arrayAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerOne.playerState!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't appended locally!")
        }
        _ = [0, 1, 2].map { card in
            XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't appended in firebase!")
        }
        
        await playerOne.updatePlayer(["cards_in_hand": [3]], arrayAction: .append)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand.contains(3), "TESTUPDATEPLAYER: single card: 3 wasn't removed locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand.contains(3), "TESTUPDATEPLAYER: single card: 3 wasn't removed in firebase!")

        // cardAction '.remove' test
        await playerOne.updatePlayer(["cards_in_hand": [0, 1, 2, 3]], arrayAction: .remove)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerOne.playerState!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't removed locally!")
        }
        _ = [0, 1, 2, 3].map { card in
            XCTAssertFalse(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand.contains(card), "TESTUPDATEPLAYER: card: \(card) wasn't removed in firebase!")
        }
        
        // cardAction '.replace' test
        await playerOne.updatePlayer(["cards_in_hand": [0, 1, 2, 3]], arrayAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.playerState!.cards_in_hand == [0, 1, 2, 3], "TESTUPDATEPLAYER: cards weren't replaced locally!")
        XCTAssertTrue(playerTwo.players.first(where: { player in player.name == "1"})!.cards_in_hand == [0, 1, 2, 3], "TESTUPDATEPLAYER: cards weren't replaced in firebase!")
        
        // modify other player's state (ONLY MEANT TO BE USED BY LEAD)
        await playerOne.updatePlayer(["cards_in_hand": [2, 3]], uid: playerTwo.playerState!.uid, arrayAction: .replace)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand == [2, 3], "TESTUPDATEPLAYER: cards weren't replaced locally!")
        XCTAssertTrue(playerOne.players.first(where: { player in player.name == "2"})!.cards_in_hand == [2, 3], "TESTUPDATEPLAYER: cards weren't replaced in firebase!")

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdateTeam() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.updateTeam(["points": 50])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertTrue(playerOne.teamState!.points == 50, "TESTUPDATETEAM: teamState wasn't updated locally!")
        XCTAssertTrue(playerTwo.teams.first(where: { team in team.team_num == 1})!.points == 50, "TESTUPDATETEAM: teamState wasn't updated in firebase!")
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testShuffleAndDeal() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // test that players have correct number of cards in hands
        await playerOne.updateGame(["dealer": 0])
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)

        XCTAssertNotEqual(playerOne.gameState!.cards, playerOne.gameState!.cards.sorted())
        XCTAssertTrue(playerOne.playerState!.cards_in_hand.count == 6)
        XCTAssertTrue(playerTwo.playerState!.cards_in_hand.count == 6)
        XCTAssertTrue(playerOne.gameState!.starter_card != -1)
        XCTAssertFalse(playerOne.gameState!.cards.contains(playerOne.gameState!.starter_card))
        
        // add another player (3)
        await playerOne.resetGame()
        await playerOne.updateGame(["dealer": 0])
        let playerThree = GameHelper()
        await playerThree.joinGameCollection(fullName: "3", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertEqual(playerOne.playerState!.cards_in_hand.count, 5)
        XCTAssertEqual(playerTwo.playerState!.cards_in_hand.count, 5)
        XCTAssertEqual(playerThree.playerState!.cards_in_hand.count, 5)
        XCTAssertEqual(playerOne.gameState!.crib.count, 1)
        
        // add another player (4)
        await playerOne.resetGame()
        await playerOne.updateGame(["dealer": 0])
        let playerFour = GameHelper()
        await playerFour.joinGameCollection(fullName: "4", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerOne.shuffleAndDealCards()
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        XCTAssertEqual(playerOne.playerState!.cards_in_hand.count, 5)
        XCTAssertEqual(playerTwo.playerState!.cards_in_hand.count, 5)
        XCTAssertEqual(playerThree.playerState!.cards_in_hand.count, 5)
        XCTAssertEqual(playerFour.playerState!.cards_in_hand.count, 5)
        XCTAssertEqual(playerOne.gameState!.crib.count, 0)
        
        // add another two players (6)
        await playerOne.resetGame()
        await playerOne.updateGame(["dealer": 0])
        let playerFive = GameHelper()
        await playerFive.joinGameCollection(fullName: "5", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        let playerSix = GameHelper()
        await playerSix.joinGameCollection(fullName: "6", id: "\(randId)")
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
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        // test normal runs
        XCTAssertEqual(playerOne.checkForRun([0, 1, 2]), 3)
        XCTAssertEqual(playerOne.checkForRun([2, 4, 16]), 3)
        XCTAssert(playerOne.checkForRun([0, 1, 51]) == 0)
        XCTAssert(playerOne.checkForRun([11, 12, 13]) == 0)
        XCTAssert(playerOne.checkForRun([2, 0, 1, 3]) == 4)
        XCTAssert(playerOne.checkForRun([13, 11, 12]) == 0)
        XCTAssert(playerOne.checkForRun([11, 12]) == 0)
        XCTAssert(playerOne.checkForRun([0, 12]) == 0)
        XCTAssertEqual(playerOne.checkForRun([2, 1, 39]), 3)
        XCTAssertEqual(playerOne.checkForRun([2,4,5,0,1,6,3]), 7)
        
        // test runs with pairs inside (in show)
        var scoringCards: [ScoringHand] = []
        var points = 0

        // Modify the XCTAssert line and keep the playerOne.checkForRun command
        playerOne.checkForRun([0,1,1,2], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .run && $0.cardsInScoredHand == [0,1,2] }))
        
        points = 0
        scoringCards = []
        playerOne.checkForRun([13,41,27,15], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .run && $0.cardsInScoredHand == [13,27,41] }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .run && $0.cardsInScoredHand == [13,27,15] }))

        points = 0
        scoringCards = []
        playerOne.checkForRun([0,1,1,2,2], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .run && $0.cardsInScoredHand == [0,1,2] }))
        
        points = 0
        scoringCards = []
        playerOne.checkForRun([4,4,5,6,6], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .run && $0.cardsInScoredHand == [4,5,6] }))
        
        points = 0
        scoringCards = []
        playerOne.checkForRun([17,30,18,45,6], &scoringCards, &points)
        print(scoringCards)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .run && $0.cardsInScoredHand == [17,18,45] }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .run && $0.cardsInScoredHand == [30,18,45] }))
        
        await playerOne.deleteGameCollection(id: randId)
    }

    @MainActor func testCheckForFifteens() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)

        var scoringCards: [ScoringHand] = []
        var points = 0
        
        playerOne.checkForSum([9,4], 15, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [9,4] && $0.cumlativePoints == 2 }))

        points = 0
        scoringCards = []
        playerOne.checkForSum([2,3,15,16,7], 15, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [2, 3, 7] && $0.cumlativePoints == 2 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [2, 16, 7] && $0.cumlativePoints == 4 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [3, 15, 7] && $0.cumlativePoints == 6 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [15, 16, 7] && $0.cumlativePoints == 8 }))

        points = 0
        scoringCards = []
        playerOne.checkForSum([3,4,6,8,5], 15, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [3, 4, 5] && $0.cumlativePoints == 2 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [8, 5] && $0.cumlativePoints == 4 }))

        points = 0
        scoringCards = []
        playerOne.checkForSum([9,12,11,10,4], 15, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [9, 4] && $0.cumlativePoints == 2 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [12, 4] && $0.cumlativePoints == 4 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [11, 4] && $0.cumlativePoints == 6 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [10, 4] && $0.cumlativePoints == 8 }))

        points = 0
        scoringCards = []
        playerOne.checkForSum([25,38,11,49,4], 15, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [25, 4] && $0.cumlativePoints == 2 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [38, 4] && $0.cumlativePoints == 4 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [11, 4] && $0.cumlativePoints == 6 }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .sum && $0.cardsInScoredHand == [49, 4] && $0.cumlativePoints == 8 }))

        await playerOne.deleteGameCollection(id: randId)
    }

    @MainActor func testCheckForSets() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        var scoringCards: [ScoringHand] = []
        var points = 0
        
        // test for basic sets
        playerOne.checkForSets([0,13], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [0, 13] }))

        points = 0
        scoringCards = []
        playerOne.checkForSets([0,13,1,14], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [0, 13] }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [1, 14] }))

        points = 0
        scoringCards = []
        playerOne.checkForSets([0,13,26], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [0, 13, 26] }))

        points = 0
        scoringCards = []
        playerOne.checkForSets([0,13,26,39], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [0, 13, 26, 39] }))

        // test for sets mixed in with other cards
        points = 0
        scoringCards = []
        playerOne.checkForSets([0,1,2,13,4], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [0, 13] }))
        
        points = 0
        scoringCards = []
        playerOne.checkForSets([0,14,5,1,13], &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [0, 13] }))
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .set && $0.cardsInScoredHand == [1, 14] }))

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testCheckForFlush() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        var scoringCards: [ScoringHand] = []
        var points = 0
        
        // test for basic flushes
        playerOne.checkForFlush([0,1,2,3], 51, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .flush && $0.cardsInScoredHand == [0, 1, 2, 3] && $0.cumlativePoints == 4 }))
        
        points = 0
        scoringCards = []
        playerOne.checkForFlush([0,1,2,3], 4, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .flush && $0.cardsInScoredHand == [0, 1, 2, 3, 4] && $0.cumlativePoints == 5 }))
        
        points = 0
        scoringCards = []
        playerOne.checkForFlush([0,1,15,3], 51, &scoringCards, &points)
        XCTAssertEqual(scoringCards.count, 0)

        await playerOne.deleteGameCollection(id: randId)
    }

    @MainActor func testCheckForNobs() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        var scoringCards: [ScoringHand] = []
        var points = 0
        
        // test for basic flushes
        playerOne.checkForNobs([0,1,2,10], 4, &scoringCards, &points)
        print(scoringCards)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .nobs }))
        
        if let nobScoreHand = scoringCards.first(where: { $0.scoreType == .nobs }) {
            XCTAssertTrue(nobScoreHand.cardsInScoredHand == [10])
            XCTAssertTrue(nobScoreHand.cumlativePoints == 1)
        }
                
        points = 0
        scoringCards = []
        playerOne.checkForNobs([23,13,2,18], 14, &scoringCards, &points)
        XCTAssertTrue(scoringCards.contains(where: { $0.scoreType == .nobs }))
        
        if let nobScoreHand = scoringCards.first(where: { $0.scoreType == .nobs }) {
            XCTAssertTrue(nobScoreHand.cardsInScoredHand == [23])
            XCTAssertTrue(nobScoreHand.cumlativePoints == 1)
        }
        
        points = 0
        scoringCards = []
        playerOne.checkForNobs([0,1,2,3], 4, &scoringCards, &points)
        XCTAssertEqual(scoringCards.count, 0)

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testManagePlayTurn() async {
        var result = 0
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        var dummyCallout: [String] = []
        await playerOne.updatePlayer(["cards_in_hand": [0,1,2,3,4,5]], arrayAction: .replace)
        await playerTwo.updatePlayer(["cards_in_hand": [0,1,2,3,4,5]], arrayAction: .replace)
        
        // test for sum of 15
        await playerOne.updateGame(["running_sum": 5])
        await playerOne.updateGame(["play_cards": [] as! [Int]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 11, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 2)
        
        // test for not going over 31
        await playerOne.updateGame(["running_sum": 22])
        await playerOne.updateGame(["play_cards": [] as! [Int]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 11, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, -1)
        XCTAssertEqual(playerOne.gameState!.running_sum, 22)
        
        // test for sum of 31
        await playerOne.updateGame(["running_sum": 21])
        await playerOne.updateGame(["play_cards": [] as! [Int]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 11, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 2)
        
        // test for pair
        await playerOne.updateGame(["play_cards": [0] as! [Int]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 26, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 2)
        
        // test for pair royal
        await playerOne.updateGame(["play_cards": [0, 13] as! [Int]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 26, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 6)
        
        // test for double pair royal
        await playerOne.updateGame(["play_cards": [0, 13, 39] as! [Int]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 26, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 12)
        
        // test for sequence of 3
        await playerOne.updateGame(["running_sum": 0])
        await playerOne.updateGame(["play_cards": [2, 4]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 16, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 3)
        
        // test for NOT sequence of 3, but pair
        await playerOne.updateGame(["play_cards": [9, 8, 7]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 20, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 2)
        
        // test for sequence of 4
        await playerOne.updateGame(["running_sum": 0, "num_cards_in_play": 1, "play_cards": [0, 2, 3]], arrayAction: .replace)
//        await playerOne.updateGame(["num_cards_in_play": 1])
//        await playerOne.updateGame(["play_cards": [0, 2, 3]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 14, pointsCallOut: &dummyCallout)
        print("callout \(dummyCallout)")
        XCTAssertEqual(result, 4)
        
        // test for sequence of 5
        await playerOne.updateGame(["running_sum": 0])
        await playerOne.updateGame(["play_cards": [0, 2, 3, 4]], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 1, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 5)
        
        // test when last in a go
        await playerOne.updateGame(["num_go": 1])
        result = await playerOne.managePlayTurn(cardInPlay: nil, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 1)
        
        // test when first or in the middle of a go
        await playerOne.updateGame(["num_go": 0])
        result = await playerOne.managePlayTurn(cardInPlay: nil, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 0)
        
        // test for num_go going back to 0 with valid card
        XCTAssertEqual(playerOne.gameState!.num_go, 1)
        _ = await playerOne.managePlayTurn(cardInPlay: 0, pointsCallOut: &dummyCallout)
        XCTAssertEqual(playerOne.gameState!.num_go, 0)
        
        // test for last card point
        await playerOne.updateGame(["running_sum": 0, "num_cards_in_play": 7], arrayAction: .replace)
        result = await playerOne.managePlayTurn(cardInPlay: 51, pointsCallOut: &dummyCallout)
        XCTAssertEqual(result, 1)

        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testCheckPlayerHandForPoints() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        // A, 2, 3, 5, 10, Q
        var scoringPlays = playerOne.checkCardsForPoints(playerCards: [0,1,2,4,9], 11)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .run }))
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .sum }))
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .flush }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .run }.count, 1)
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .sum }.count, 4)
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .flush }.count, 1)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 16)
        
        // 8, 7, 6, 5, J
        scoringPlays = playerOne.checkCardsForPoints(playerCards: [34,33,6,18], 11)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .run }))
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .sum }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .run }.count, 1)
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .sum }.count, 2)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 8)
        
        // Q, K, Q, K, Q
        scoringPlays = playerOne.checkCardsForPoints(playerCards: [37,51,24,25], 11)
        print(scoringPlays)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .set }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .set }.count, 2)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 8)
        
        // 9, 7, A, 8, 6
        scoringPlays = playerOne.checkCardsForPoints(playerCards: [8,6,0,20], 18)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .run }))
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .sum }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .run }.count, 1)
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .sum }.count, 3)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 10)
        
        // A, 2, 3, 7, 10
        scoringPlays = playerOne.checkCardsForPoints(playerCards: [0,1,2,19], 22)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .run }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .run }.count, 1)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 5)
        
        await playerOne.deleteGameCollection(id: randId)
        
        // A, 2, 2, 3, 6
        scoringPlays = playerOne.checkCardsForPoints(playerCards: [0,1,14,15], 5)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .run }))
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .set }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .run }.count, 2)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 8)
        
        // A, 2, 2, 2, 3
        scoringPlays = playerOne.checkCardsForPoints(playerCards: [0,1,14,27], 2)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .run }))
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .set }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .run }.count, 3)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 15)
        
        // 9, 10, J, Q, K
        scoringPlays = playerOne.checkCardsForPoints(playerCards: [8,9,23,11],12)
        XCTAssertTrue(scoringPlays.contains(where: { $0.scoreType == .run }))
        
        XCTAssertEqual(scoringPlays.filter { $0.scoreType == .run }.count, 1)
        XCTAssertEqual(scoringPlays.last!.cumlativePoints, 5)
        
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testUpdatePlayerNums() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        let playerTwo = GameHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        // manual checks
        await playerOne.updatePlayer(["player_num": 4])
        await playerTwo.updatePlayer(["player_num": 7])
        
        await playerOne.reorderPlayerNumbers()

        XCTAssertTrue(playerOne.playerState!.player_num == 0)
        XCTAssertTrue(playerTwo.playerState!.player_num == 1)
        
        // game simulation check
        let playerThree = GameHelper()
        await playerThree.joinGameCollection(fullName: "3", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 0.25)
        
        await playerTwo.changeTeam(newTeamNum: 3)
        await playerThree.changeTeam(newTeamNum: 2)
        
        await playerOne.reorderPlayerNumbers()
        
        XCTAssertTrue(playerTwo.playerState!.player_num == 2)
        XCTAssertTrue(playerThree.playerState!.player_num == 1)
        
        // more players
        let playerFour = GameHelper()
        await playerFour.joinGameCollection(fullName: "4", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerFive = GameHelper()
        await playerFive.joinGameCollection(fullName: "5", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        let playerSix = GameHelper()
        await playerSix.joinGameCollection(fullName: "6", id: "\(randId)")
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1)
        
        await playerOne.changeTeam(newTeamNum: 3)
        await playerTwo.changeTeam(newTeamNum: 3)
        await playerThree.changeTeam(newTeamNum: 2)
        await playerFour.changeTeam(newTeamNum: 1)
        await playerFive.changeTeam(newTeamNum: 2)
        await playerSix.changeTeam(newTeamNum: 1)
        
        await playerOne.reorderPlayerNumbers()
        
        XCTAssertEqual(playerOne.playerState!.player_num, 5)
        XCTAssertEqual(playerTwo.playerState!.player_num, 2)
        XCTAssertEqual(playerThree.playerState!.player_num, 1)
        XCTAssertEqual(playerFour.playerState!.player_num, 0)
        XCTAssertEqual(playerFive.playerState!.player_num, 4)
        XCTAssertEqual(playerSix.playerState!.player_num, 3)
                
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testCheckGameInProgress() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        var result = await playerOne.checkGameInProgress(id: "\(randId)")
        XCTAssertFalse(result)
        
        await playerOne.updateGame(["is_playing": true])
        result = await playerOne.checkGameInProgress(id: "\(randId)")
        XCTAssertTrue(result)
                
        await playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testDeleteGame() async {
        let playerOne = GameHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: "\(randId)"))
        await playerOne.startGameCollection(fullName: "1", testGroupId: randId)
        
        await playerOne.deleteGameCollection(id: randId)
        let validity = await playerOne.checkValidId(id: "\(randId)")
        XCTAssertFalse(validity)
    }
}


