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
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerOne.gameInfo!.cards.count == 46)
        XCTAssert(playerOne.playerInfo!.cards_in_hand!.count == 6)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        cardsInHand_Binding = []
        await playerTwo.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerTwo.gameInfo!.cards.count == 40)
        XCTAssert(playerTwo.playerInfo!.cards_in_hand!.count == 6)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testThreePlayerDeal() async {
        let playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        playerOne.updatePlayer(newState: ["is_dealer": true])
        playerOne.updateTeam(newState: ["has_crib": true])
        
        var playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        
        var playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: randId, gameName: "Cribbage")
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        XCTAssert(playerOne.teamInfo!.crib.count == 1)
        var teamWithCrib = playerThree.teams.first(where: { team in
            team.has_crib
        })
        XCTAssert(teamWithCrib?.team_num == playerOne.teamInfo!.team_num, "Other players couldn't get the teamWithCrib information!")
        XCTAssert(teamWithCrib?.crib.count == 1)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testFourPlayerDeal() async {
        var playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        playerOne.updatePlayer(newState: ["is_dealer": true])
        playerOne.updateTeam(newState: ["has_crib": true])
        
        var playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        
        var playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: randId, gameName: "Cribbage")
        
        var playerFour = FirebaseHelper()
        await playerFour.joinGameCollection(fullName: "4", id: randId, gameName: "Cribbage")
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerOne.gameInfo!.cards.count == 47)
        XCTAssert(playerOne.playerInfo!.cards_in_hand!.count == 5)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        cardsInHand_Binding = []
        await playerTwo.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerTwo.gameInfo!.cards.count == 42)
        XCTAssert(playerTwo.playerInfo!.cards_in_hand!.count == 5)
        
        XCTAssert(playerOne.teamInfo!.crib.count == 0)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
    @MainActor func testSixPlayerDeal() async {
        var playerOne = FirebaseHelper()
        var randId = 0
        repeat {
            randId = Int.random(in: 10000..<99999)
        } while (await playerOne.checkValidId(id: randId))
        
        await playerOne.startGameCollection(fullName: "1", gameName: "Cribbage", testGroupId: randId)
        playerOne.updatePlayer(newState: ["is_dealer": true])
        playerOne.updateTeam(newState: ["has_crib": true])
        
        var playerTwo = FirebaseHelper()
        await playerTwo.joinGameCollection(fullName: "2", id: randId, gameName: "Cribbage")
        
        var playerThree = FirebaseHelper()
        await playerThree.joinGameCollection(fullName: "3", id: randId, gameName: "Cribbage")
        
        var playerFour = FirebaseHelper()
        await playerFour.joinGameCollection(fullName: "4", id: randId, gameName: "Cribbage")
        
        var playerFive = FirebaseHelper()
        await playerFive.joinGameCollection(fullName: "5", id: randId, gameName: "Cribbage")
        
        var playerSix = FirebaseHelper()
        await playerSix.joinGameCollection(fullName: "6", id: randId, gameName: "Cribbage")
        
        var cardsInHand_Binding: [CardItem] = []
        await playerOne.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerOne.gameInfo!.cards.count == 48)
        XCTAssert(playerOne.playerInfo!.cards_in_hand!.count == 4)
        XCTAssert(playerOne.teamInfo!.crib.count == 0)
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        
        cardsInHand_Binding = []
        await playerTwo.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerTwo.gameInfo!.cards.count == 43)
        XCTAssert(playerTwo.playerInfo!.cards_in_hand!.count == 5)
        
        cardsInHand_Binding = []
        await playerSix.shuffleAndDealCards(cardsInHand_binding: Binding(get: { cardsInHand_Binding }, set: { cardsInHand_Binding = $0 }))
        XCTAssert(playerSix.playerInfo!.cards_in_hand!.count == 4)
        
        playerOne.deleteGameCollection(id: randId)
    }
}
