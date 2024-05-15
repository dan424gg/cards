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
    
    func deleteGameCollection(id: Int) async
}

struct Firebase: Database {
    private var db = Firestore.firestore()
    private var docRef: DocumentReference!
    
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws {
        try await docRef.collection("players").document(uid).updateData([key: value])
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
        try await docRef.collection("players").document(uid).updateData([key: fieldValue])
    }
    
    func updateGameField<T>(key: String, value: T) async throws {
        try await docRef.updateData([key: value])
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
        try await docRef.updateData([key: fieldValue])
    }
    
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws {
        try await docRef.collection("teams").document("\(teamNum)").updateData([key: value])
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
