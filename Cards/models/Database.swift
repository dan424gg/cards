//
//  Database.swift
//  Cards
//
//  Created by Daniel Wells on 5/15/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol Database {
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws
    func updatePlayerArrayField<T>(uid: String, key: String, value: [T], action: ArrayActionType) async throws
    func updateGameField<T>(key: String, value: T) async throws
    func updateGameArrayField<T>(key: String, value: [T], action: ArrayActionType) async throws
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws

    mutating func setDocRef(_ groupId: Int)
    func setInitGameState(_ gameState: GameState) throws
    func getGameState() async throws -> GameState
    func getGameState(_ groupId: Int) async throws -> GameState
    func setInitTeamState(_ teamState: TeamState) throws
    func getTeamState(_ teamNum: Int) async throws -> TeamState
    func setInitPlayerState(_ playerState: PlayerState) throws
    
    func checkGameExists(groupId: Int) async throws -> Bool
    func checkTeamExists(teamNum: Int) async throws -> Bool
    func deleteGameCollection(id: Int) async
}

struct Firebase: Database {
    private var db = Firestore.firestore()
    private var docRef: DocumentReference?
    
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws {
        try await docRef!.collection("players").document(uid).updateData([key: value])
    }
    
    func updatePlayerArrayField<T>(uid: String, key: String, value: [T], action: ArrayActionType) async throws {
        let fieldValue: FieldValue
        switch action {
            case .append:
                fieldValue = FieldValue.arrayUnion(value)
            case .remove:
                fieldValue = FieldValue.arrayRemove(value)
            case .replace:
                try await updatePlayerField(uid: uid, key: key, value: value)
                return
        }
        try await docRef!.collection("players").document(uid).updateData([key: fieldValue])
    }
    
    func updateGameField<T>(key: String, value: T) async throws {
        try await docRef!.updateData([key: value])
    }
    
    func updateGameArrayField<T>(key: String, value: [T], action: ArrayActionType) async throws {
        let fieldValue: FieldValue
        switch action {
            case .append:
                fieldValue = FieldValue.arrayUnion(value)
            case .remove:
                fieldValue = FieldValue.arrayRemove(value)
            case .replace:
                try await updateGameField(key: key, value: value)
                return
        }
        try await docRef!.updateData([key: fieldValue])
    }
    
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws {
        try await docRef!.collection("teams").document("\(teamNum)").updateData([key: value])
    }
    
    mutating func setDocRef(_ groupId: Int) {
        docRef = db.collection("game").document("\(groupId)")
        print("got here \(db.collection("game").document("\(groupId)"))")
    }
    
    func setInitGameState(_ gameState: GameState) throws {
        try docRef!.setData(from: gameState)
    }
    
    func getGameState() async throws -> GameState {
        guard let docRef = docRef else {
            return GameState()
        }
        
        return try await docRef.getDocument().data(as: GameState.self)
    }
    
    func getGameState(_ groupId: Int) async throws -> GameState {        
        return try await db.collection("games").document("\(groupId)").getDocument(as: GameState.self)
    }
    
    func setInitTeamState(_ teamState: TeamState) throws {
        try docRef!.collection("teams").document("1").setData(from: teamState)
    }
    
    func getTeamState(_ teamNum: Int) async throws -> TeamState {
        guard let docRef = docRef else {
            return TeamState()
        }
        
        return try await docRef.collection("teams").document("\(teamNum)").getDocument().data(as: TeamState.self)
    }
    
    func setInitPlayerState(_ playerState: PlayerState) throws {
        try docRef!.collection("players").document(playerState.uid).setData(from: playerState)
    }
    
    func checkGameExists(groupId: Int) async throws -> Bool {
        return try await db.collection("games").document("\(groupId)").getDocument().exists
    }
    
    func checkTeamExists(teamNum: Int) async throws -> Bool {
        guard let docRef = docRef else {
            return false
        }
        
        return try await docRef.collection("teams").document("\(teamNum)").getDocument().exists
    }
    
    func deleteGameCollection(id: Int) async {
        do {
            // delete all player documents
            for doc in try await db.collection("games").document("\(id)").collection("players").getDocuments().documents {
                try await db.collection("games").document("\(id)").collection("players").document(doc.data(as: PlayerState.self).uid).delete()
            }
            
            // delete all team documents
            for doc in try await db.collection("games").document("\(id)").collection("teams").getDocuments().documents {
                try await db.collection("games").document("\(id)").collection("teams").document("\(doc.data(as: TeamState.self).team_num)").delete()
            }
            
            try await db.collection("games").document("\(id)").delete()
        } catch {
            print("error when deleting game collection: \(id)\n\(error)\n")
        }
    }
}
