//
//  Database.swift
//  Cards
//
//  Created by Daniel Wells on 5/15/24.
//

import Combine
import Foundation
import SwiftUI
import SwiftData
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol Database: Codable {
//    var playersListener: ListenerRegistration! { get set }
//    var gameListener: ListenerRegistration! { get set }
//    var teamsListener: ListenerRegistration! { get set }
    
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws
    func updatePlayerArrayField<T: Equatable>(uid: String, key: String, value: [T], action: ArrayActionType) async throws
    func updateGameField<T>(key: String, value: T) async throws
    func updateGameArrayField<T: Equatable>(key: String, value: [T], action: ArrayActionType) async throws
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws

    mutating func setDocRef(_ groupId: Int)
    func setInitGameState(_ gameState: GameState) throws
    func getGameState() async throws -> GameState
    func getGameState(_ groupId: Int) async throws -> GameState
    func setTeamState(_ teamState: TeamState, _ teamNum: Int) throws
    func getTeamState(_ teamNum: Int) async throws -> TeamState
    func setPlayerState(_ playerState: PlayerState, _ playerUid: String) throws
    
    mutating func addPlayersListener(_ playerStateRef: Reference<PlayerState>, _ playersRef: Reference<[PlayerState]>) async
    mutating func removePlayersListener()
    mutating func addGameStateListener(_ gameStateRef: Reference<GameState>) async
    mutating func removeGameStateListener()
    mutating func addTeamsListener(_ teamStateRef: Reference<TeamState>, _ teamsRef: Reference<[TeamState]>) async
    mutating func removeTeamsListener()
    
    func checkGameExists(groupId: Int) async throws -> Bool
    func checkTeamExists(teamNum: Int) async throws -> Bool
    func deleteGameCollection(id: Int) async
    func deleteTeamCollection(teamNum: Int) async throws
}


struct Firebase: Database {
    var playersListener: ListenerRegistration!
    var gameListener: ListenerRegistration!
    var teamsListener: ListenerRegistration!
    private var db = Firestore.firestore()
    private var docRef: DocumentReference?
    
    // Properties to store data needed for encoding/decoding
    private var docRefId: String?

    enum CodingKeys: String, CodingKey {
        case docRefId
    }

    init() {
        // Default initialization
    }

    // Custom initializer to support decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        docRefId = try container.decodeIfPresent(String.self, forKey: .docRefId)
        if let docRefId = docRefId {
            docRef = db.collection("games").document(docRefId)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(docRef?.documentID, forKey: .docRefId)
    }

    mutating func setDocRef(_ groupId: Int) {
        docRef = db.collection("games").document("\(groupId)")
        docRefId = "\(groupId)"
    }
    
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws {
        try await docRef!.collection("players").document(uid).updateData([key: value])
    }
    
    func updatePlayerArrayField<T: Equatable>(uid: String, key: String, value: [T], action: ArrayActionType) async throws {
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
    
    func updateGameArrayField<T: Equatable>(key: String, value: [T], action: ArrayActionType) async throws {
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
    
//    mutating func setDocRef(_ groupId: Int) {
//        docRef = db.collection("games").document("\(groupId)")
//    }
    
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
    
    func setTeamState(_ teamState: TeamState, _ teamNum: Int) throws {
        try docRef!.collection("teams").document("\(teamNum)").setData(from: teamState)
    }
    
    func getTeamState(_ teamNum: Int) async throws -> TeamState {
        guard let docRef = docRef else {
            return TeamState()
        }
        
        return try await docRef.collection("teams").document("\(teamNum)").getDocument().data(as: TeamState.self)
    }
    
    func setPlayerState(_ playerState: PlayerState, _ playerUid: String) throws {
        try docRef!.collection("players").document(playerState.uid).setData(from: playerState)
    }
    
    mutating func addPlayersListener(_ playerStateRef: Reference<PlayerState>, _ playersRef: Reference<[PlayerState]>) async {
        guard docRef != nil else {
            print("docRef is nil before adding game info listener")
            return
        }
        
        playersListener = self.docRef!.collection("players")
            .addSnapshotListener { (snapshot, e) in
                guard snapshot != nil else {
                    print("snapshot is nil")
                    return
                }
                
                do {
                    try snapshot!.documentChanges.forEach { change in
                        if change.type == .added {
                            let newPlayerData = try change.document.data(as: PlayerState.self)
                            
                            if (playerStateRef.value.player_num != newPlayerData.player_num)
                                && (!playersRef.value.contains(where: { $0.uid == newPlayerData.uid })) {
                                playersRef.value.append(newPlayerData)
                            }
                        }
                        
                        if change.type == .modified {
                                let modifiedPlayerData = try change.document.data(as: PlayerState.self)
                                
                            if modifiedPlayerData.uid == playerStateRef.value.uid {
                                playerStateRef.value = modifiedPlayerData
                                } else if let loc = playersRef.value.firstIndex(where: { $0.uid == modifiedPlayerData.uid }) {
                                    playersRef.value[loc] = modifiedPlayerData
                                }
                        }
                        
                        if change.type == .removed {
                            let removedPlayerData = try change.document.data(as: PlayerState.self)
                            
                            if let loc = playersRef.value.firstIndex(where: { $0.uid == removedPlayerData.uid }) {
                                playersRef.value.remove(at: loc)
                            }
                        }
                    }
                } catch {
                    print("error in player listener \(error)")
                }
            }
    }
    
    mutating func removePlayersListener() {
        guard playersListener != nil else {
            return
        }
        
        playersListener.remove()
    }
    
    mutating func addGameStateListener(_ gameStateRef: Reference<GameState>) async {
        guard docRef != nil else {
            print("docRef is nil before adding game info listener")
            return
        }
        
        gameListener = docRef!
            .addSnapshotListener { (snapshot, error) in
                guard snapshot != nil else {
                    print("snapshot is nil when adding a gameState listener")
                    return
                }
                
                do {
                    gameStateRef.value = try snapshot!.data(as: GameState.self)
                } catch {
                    print("couldn't add a gameState listener")
                    print(error)
                }
            }
    }
    
    mutating func removeGameStateListener() {
        guard gameListener != nil else {
            return
        }
        
        gameListener.remove()
    }
    
    mutating func addTeamsListener(_ teamStateRef: Reference<TeamState>, _ teamsRef: Reference<[TeamState]>) async {
        guard docRef != nil else {
            print("docRef is nil before adding player listener")
            return
        }

        teamsListener = docRef!.collection("teams")
                .addSnapshotListener { (snapshot, e) in
                    guard snapshot != nil else {
                        print("snapshot is nil")
                        return
                    }
                    do {
                        try snapshot?.documentChanges.forEach { change in
                            if change.type == .added {
                                let newTeam = try change.document.data(as: TeamState.self)
                                if !teamsRef.value.contains(where: {
                                    $0.team_num == newTeam.team_num
                                }) {
                                    teamsRef.value.append(newTeam)
                                }
                            }
                            
                            if change.type == .modified {
                                let modifiedTeamData = try change.document.data(as: TeamState.self)
                                if modifiedTeamData.team_num == teamStateRef.value.team_num {
                                    teamStateRef.value = modifiedTeamData
                                }
                                
                                let loc = teamsRef.value.firstIndex { team in
                                    team.team_num == modifiedTeamData.team_num
                                }
                                
                                teamsRef.value[loc!] = modifiedTeamData
                            }
                            
                            if change.type == .removed {
                                let removedTeamData = try change.document.data(as: TeamState.self)
                                let loc = teamsRef.value.firstIndex { team in
                                    team.team_num == removedTeamData.team_num
                                }
                                
                                teamsRef.value.remove(at: loc!)
                            }
                        }
                    } catch {
                        print("from team listener: \(error)")
                    }
                }
    }
    
    mutating func removeTeamsListener() {
        guard teamsListener != nil else {
            return
        }
        
        teamsListener.remove()
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
    
    func deleteTeamCollection(teamNum: Int) async throws{
        guard let docRef = docRef else {
            return
        }
        
        try await docRef.collection("teams").document("\(teamNum)").delete()
    }
}

struct Local: Database {
    @Query(filter: #Predicate<GameModel> { model in
        model.inProgress == true
    }) var models: [GameModel]
    var model: GameModel? { models.first }
    
    enum CodingKeys: String, CodingKey {
        case models
    }
    
    init() {
    }
    
    // Decodable conformance
    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.models = try container.decode([GameModel].self, forKey: .models)
    }
    
    // Encodable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(models, forKey: .models)
    }
    
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws {
        guard let model = model, let playerState = model.playerState else {
            return
        }

        if playerState.uid == uid {
            model.playerState![key] = value
        } else if let idx = model.players.firstIndex(where: { $0.uid == uid }) {
            model.players[idx][key] = value
        }
    }
    
    func updatePlayerArrayField<T: Equatable>(uid: String, key: String, value: [T], action: ArrayActionType) async throws {
        guard let model = model, let playerState = model.playerState else {
            return
        }

        if playerState.uid == uid {
            switch action {
                case .append:
                    if var lookUp = model.playerState![key] as? [T] {
                        lookUp.append(contentsOf: value)
                    }
                case .remove:
                    if var lookUp = model.playerState![key] as? [T] {
                        for val in value {
                            lookUp.removeAll(where: {
                                $0 == val
                            })
                        }
                    }
                case .replace:
                    model.playerState![key] = value
            }
        } else if let idx = model.players.firstIndex(where: { $0.uid == uid }) {
            switch action {
                case .append:
                    if var lookUp = model.players[idx][key] as? [T] {
                        lookUp.append(contentsOf: value)
                    }
                case .remove:
                    if var lookUp = model.players[idx][key] as? [T] {
                        for val in value {
                            lookUp.removeAll(where: {
                                $0 == val
                            })
                        }
                    }
                case .replace:
                    model.players[idx][key] = value
            }
        }
    }
    
    func updateGameField<T>(key: String, value: T) async throws {
        guard let model = model, model.gameState != nil else {
            return
        }
        
        model.gameState![key] = value
    }
    
    func updateGameArrayField<T: Equatable>(key: String, value: [T], action: ArrayActionType) async throws {
        guard let model = model, model.gameState != nil else {
            return
        }
        
        switch action {
            case .append:
                if var lookUp = model.gameState![key] as? [T] {
                    lookUp.append(contentsOf: value)
                }
            case .remove:
                if var lookUp = model.gameState![key] as? [T] {
                    for val in value {
                        lookUp.removeAll(where: {
                            $0 == val
                        })
                    }
                }
            case .replace:
                model.gameState![key] = value
        }
    }
    
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws {
        guard let model = model, var teamState = model.teamState else {
            return
        }

        if teamState.team_num == teamNum {
            teamState[key] = value
        } else if let idx = model.teams.firstIndex(where: { $0.team_num == teamNum }) {
            model.teams[idx][key] = value
        }
    }
    
    func setDocRef(_ groupId: Int) { /* don't need this function */ }
    
    func setInitGameState(_ gameState: GameState) throws {
        guard let model = model else {
            return
        }
        
        model.gameState = gameState
    }
    
    func getGameState() async throws -> GameState {
        guard let model = model, let gameState = model.gameState else {
            return GameState()
        }
        
        return gameState
    }
    
    func getGameState(_ groupId: Int) async throws -> GameState {
        /* don't need this function */
        return GameState()
    }
    
    func setTeamState(_ teamState: TeamState, _ teamNum: Int) throws {
        guard let model = model else {
            return
        }
        
        model.teams.append(teamState)
    }
    
    func getTeamState(_ teamNum: Int) async throws -> TeamState {
        guard let model = model else {
            return TeamState()
        }
        
        if let idx = model.teams.firstIndex(where: { $0.team_num == teamNum }) {
            return model.teams[idx]
        } else {
            return TeamState()
        }
    }
    
    func setPlayerState(_ playerState: PlayerState, _ playerUid: String) throws {
        guard let model = model else {
            return
        }
        
        model.players.append(playerState)
    }
    
    func addPlayersListener(_ playerStateRef: Reference<PlayerState>, _ playersRef: Reference<[PlayerState]>) async {
        // POSSIBLE SOLUTIONS
//        @MainActor
//        private func logIn(applicationState: OrdoApplication) {
//            if applicationState.loginState == .loggedIn {
//                runTests(applicationState: applicationState)
//            } else {
//                withObservationTracking {
//                    _ = applicationState.loginState
//                } onChange: {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.logIn(applicationState: applicationState)
//                    }
//                }
//            }
//        }
        
        /* import Observation
         
         @Observable class SourceOfTruth {
             var data: Int = 0
         }

         let sourceOfTruth = SourceOfTruth()

         func test() {
             withObservationTracking {
                 _ = sourceOfTruth.data
             } onChange: {
                 print("changed: ", sourceOfTruth.data)
                 test()
             }
         }

         func foo() {
             Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                 sourceOfTruth.data += 1
             }
             test()
         } */
    }
    
    func removePlayersListener() {
        /* don't need this function */
    }
    
    func addGameStateListener(_ gameStateRef: Reference<GameState>) async {
        /* don't need this function */
    }
    
    func removeGameStateListener() {
        /* don't need this function */
    }
    
    func addTeamsListener(_ teamStateRef: Reference<TeamState>, _ teamsRef: Reference<[TeamState]>) async {
        /* don't need this function */
    }
    
    func removeTeamsListener() {
        /* don't need this function */
    }
    
    func checkGameExists(groupId: Int) async throws -> Bool {
        /* don't need this function */
        return false
    }
    
    func checkTeamExists(teamNum: Int) async throws -> Bool {
        /* don't need this function */
        return false
    }
    
    func deleteGameCollection(id: Int) async {
        /* don't need this function */
    }
    
    func deleteTeamCollection(teamNum: Int) async throws {
        /* don't need this function */
    }
}
