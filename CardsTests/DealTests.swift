//
//  DealTests.swift
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

final class DealTests: XCTestCase {
    @MainActor func testTwoPlayerDeal() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        
        let playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        
        var cardsInHand_Binding: [Int] = []
        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        XCTAssert(playerOne.gameState!.cards.count == 46)
//        XCTAssert(playerOne.playerState!.cards_in_hand!.count == 6)
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        
//        cardsInHand_Binding = []
//        await playerTwo.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        XCTAssert(playerTwo.gameState!.cards.count == 40)
//        XCTAssert(playerTwo.playerState!.cards_in_hand!.count == 6)
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//
//        var playerOneCards = playerOne.playerState!.cards_in_hand!
//        for card in playerOneCards {
//            XCTAssertFalse(playerTwo.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during twoPlayerDeal!")
//        }
        
        playerOne.deleteGameCollection(id: randId)
    }
    
//    @MainActor func testThreePlayerDeal() async {
//        let playerOne = FirebaseHelper()
//        var randId = 0
//        repeat {
//            randId = Int.random(in: 10000..<99999)
//        } while (await playerOne.checkValidId(id: randId))
//        
//        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
//        
//        var playerTwo = FirebaseHelper()
//        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
//        
//        var playerThree = FirebaseHelper()
//        await playerThree.joinGameCollection(fullName: "3", id: randId, gameName: "Cribbage")
//        
//        var cardsInHand_Binding: [CardItem] = []
//        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        XCTAssert(playerOne.gameState!.cards.count == 46)
//        XCTAssert(playerOne.playerState!.cards_in_hand!.count == 5)
//        
//        cardsInHand_Binding = []
//        await playerTwo.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        XCTAssert(playerOne.gameState!.cards.count == 41)
//        XCTAssert(playerTwo.playerState!.cards_in_hand!.count == 5)
//        
//        cardsInHand_Binding = []
//        await playerThree.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        XCTAssert(playerOne.gameState!.cards.count == 36)
//        XCTAssert(playerThree.playerState!.cards_in_hand!.count == 5)
//        
//        var playerOneCards = playerOne.playerState!.cards_in_hand!
//        for card in playerOneCards {
//            XCTAssertFalse(playerTwo.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during threePlayerDeal!")
//        }
//        
//        var playerTwoCards = playerTwo.playerState!.cards_in_hand!
//        for card in playerTwoCards {
//            XCTAssertFalse(playerThree.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during threePlayerDeal!")
//        }
//        
//        var playerThreeCards = playerThree.playerState!.cards_in_hand!
//        for card in playerThreeCards {
//            XCTAssertFalse(playerOne.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during threePlayerDeal!")
//        }
//        
//        XCTAssert(playerOne.teamState!.crib.count == 1)
//        var teamWithCrib = playerThree.teams.first(where: { team in
//            team.has_crib
//        })
//        XCTAssert(teamWithCrib?.team_num == playerOne.teamState!.team_num, "Other players couldn't get the teamWithCrib information!")
//        XCTAssert(teamWithCrib?.crib.count == 1)
//        
//        playerOne.deleteGameCollection(id: randId)
//    }
//    
//    @MainActor func testFourPlayerDeal() async {
//        var playerOne = FirebaseHelper()
//        var randId = 0
//        repeat {
//            randId = Int.random(in: 10000..<99999)
//        } while (await playerOne.checkValidId(id: randId))
//        
//        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
//        playerOne.updatePlayer(newState: ["is_dealer": true])
//        playerOne.updateTeam(newState: ["has_crib": true])
//        
//        var playerTwo = FirebaseHelper()
//        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
//        
//        var playerThree = FirebaseHelper()
//        await playerThree.joinGameCollection(fullName: "3", id: randId, gameName: "Cribbage")
//        
//        var playerFour = FirebaseHelper()
//        await playerFour.joinGameCollection(fullName: "4", id: randId, gameName: "Cribbage")
//        
//        var cardsInHand_Binding: [CardItem] = []
//        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        XCTAssert(playerOne.gameState!.cards.count == 47)
//        XCTAssert(playerOne.playerState!.cards_in_hand!.count == 5)
//        
//        cardsInHand_Binding = []
//        await playerTwo.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        XCTAssert(playerOne.gameState!.cards.count == 42)
//        XCTAssert(playerTwo.playerState!.cards_in_hand!.count == 5)
//        
//        cardsInHand_Binding = []
//        await playerThree.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        XCTAssert(playerOne.gameState!.cards.count == 37)
//        XCTAssert(playerThree.playerState!.cards_in_hand!.count == 5)
//        
//        cardsInHand_Binding = []
//        await playerFour.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        XCTAssert(playerOne.gameState!.cards.count == 32)
//        XCTAssert(playerFour.playerState!.cards_in_hand!.count == 5)
//        
//        var playerOneCards = playerOne.playerState!.cards_in_hand!
//        for card in playerOneCards {
//            XCTAssertFalse(playerTwo.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during fourPlayerDeal!")
//        }
//        
//        var playerTwoCards = playerTwo.playerState!.cards_in_hand!
//        for card in playerTwoCards {
//            XCTAssertFalse(playerThree.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during fourPlayerDeal!")
//        }
//        
//        var playerThreeCards = playerThree.playerState!.cards_in_hand!
//        for card in playerThreeCards {
//            XCTAssertFalse(playerFour.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during fourPlayerDeal!")
//        }
//        
//        var playerFourCards = playerFour.playerState!.cards_in_hand!
//        for card in playerFourCards {
//            XCTAssertFalse(playerOne.gameState!.cards.contains(where: { deckCard in deckCard == card}), "\(card) was found in the deck of cards during fourPlayerDeal!")
//        }
//        
//        XCTAssert(playerOne.teamState!.crib.count == 0)
//        
//        playerOne.deleteGameCollection(id: randId)
//    }
//    
//    @MainActor func testSixPlayerDeal() async {
//        let playerOne = FirebaseHelper()
//        var randId = 0
//        repeat {
//            randId = Int.random(in: 10000..<99999)
//        } while (await playerOne.checkValidId(id: randId))
//        
//        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
//        playerOne.updatePlayer(newState: ["is_dealer": true])
//        playerOne.updateTeam(newState: ["has_crib": true])
//        
//        let playerTwo = FirebaseHelper()
//        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
//        
//        let playerThree = FirebaseHelper()
//        await playerThree.joinGameCollection(fullName: "3", id: randId, gameName: "Cribbage")
//        
//        let playerFour = FirebaseHelper()
//        await playerFour.joinGameCollection(fullName: "4", id: randId, gameName: "Cribbage")
//        
//        let playerFive = FirebaseHelper()
//        await playerFive.joinGameCollection(fullName: "5", id: randId, gameName: "Cribbage")
//        
//        let playerSix = FirebaseHelper()
//        await playerSix.joinGameCollection(fullName: "6", id: randId, gameName: "Cribbage")
//        
//        var cardsInHand_Binding: [CardItem] = []
//        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        XCTAssert(playerOne.gameState!.cards.count == 48)
//        XCTAssert(playerOne.playerState!.cards_in_hand!.count == 4)
//        XCTAssert(playerOne.teamState!.crib.count == 0)
//        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
//        
//        cardsInHand_Binding = []
//        await playerTwo.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        XCTAssert(playerTwo.gameState!.cards.count == 43)
//        XCTAssert(playerTwo.playerState!.cards_in_hand!.count == 5)
//        
//        cardsInHand_Binding = []
//        await playerSix.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
//        XCTAssert(playerSix.playerState!.cards_in_hand!.count == 4)
//        
//        playerOne.deleteGameCollection(id: randId)
//    }
}
