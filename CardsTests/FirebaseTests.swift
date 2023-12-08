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
            player.uid == playerTwo.playerInfo!.uid
        }))
                
        let updatedPlayer = playerTwo.players.first(where: { player in
            player.uid == playerOne.playerInfo!.uid!
        })
        
        XCTAssertTrue(updatedPlayer!.is_dealer!)
        
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
            team.team_num == playerTwo.teamInfo!.team_num
        }))
                
        let updatedTeam = playerTwo.teams.first(where: { team in
            team.team_num == playerOne.teamInfo!.team_num
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
        
        XCTAssertTrue(playerOne.gameInfo!.turn == playerTwo.gameInfo!.turn)
        
        await playerOne.updateGame(newState: ["turn": 1])
        _ = await XCTWaiter.fulfillment(of: [expectation(description: "wait for firestore to update")], timeout: 1.0)
        XCTAssertTrue(playerOne.gameInfo!.turn == playerTwo.gameInfo!.turn)
        
        playerOne.deleteGameCollection(id: randId)
    }
    
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
}


