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
import Observation

protocol Database {
    var modelContainer: ModelContainer? { get }
    
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws
    func updatePlayerArrayField<T: Equatable>(uid: String, key: String, value: [T], action: ArrayActionType) async throws
    func updateGameField<T>(key: String, value: T) async throws
    func updateGameArrayField<T: Equatable>(key: String, value: [T], action: ArrayActionType) async throws
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws

    mutating func setDocRef(_ groupId: Int)
    func setInitGameState(_ gameState: GameState) throws
    func getGameState() async throws -> GameState
    func getGameState(_ groupId: Int) async throws -> GameState
    func setInitTeamState(_ teamState: TeamState, _ teamNum: Int) throws
    func getTeamState(_ teamNum: Int) async throws -> TeamState
    func setInitPlayerState(_ playerState: PlayerState, _ playerUid: String) throws
    
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

extension Database {
    
    func create<T: PersistentModel>(_ items: [T]) throws {
        guard let modelContainer = modelContainer else {
            print("modelContainer is nil when trying to upsert a model")
            return
        }
        
        let context = ModelContext(modelContainer)
        for item in items {
            context.insert(item)
        }
        try context.save()
    }
    
    func create<T: PersistentModel>(_ item: T) throws {
        guard let modelContainer = modelContainer else {
            print("modelContainer is nil when trying to create a model")
            return
        }
        
        let context = ModelContext(modelContainer)
        context.insert(item)
        try context.save()
    }
    
    func read<T: PersistentModel>(_ predicate: Predicate<T>) throws -> [T] {
        guard let modelContainer = modelContainer else {
            print("modelContainer is nil when trying to read a model")
            return []
        }
        
        let context = ModelContext(modelContainer)
        let fetchDescriptor = FetchDescriptor<T>(
            predicate: predicate
        )
        return try context.fetch(fetchDescriptor)
    }
    
    func read<T: PersistentModel>(_ predicate: Predicate<T>, sortBy sortDescriptors: SortDescriptor<T>...) throws -> [T] {
        guard let modelContainer = modelContainer else {
            print("modelContainer is nil when trying to read a model")
            return []
        }
        
        let context = ModelContext(modelContainer)
        let fetchDescriptor = FetchDescriptor<T>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        return try context.fetch(fetchDescriptor)
    }
    
    /// Same as ```create(_ item: T)``` becuase SwiftData does an 'upsert' by default
    func update<T: PersistentModel>(_ item: T) throws {
        try create(item)
    }

    func delete<T: PersistentModel>(_ type: T.Type) throws {
        guard let modelContainer = modelContainer else {
            print("modelContainer is nil when trying to delete a model")
            return
        }
        
        let context = ModelContext(modelContainer)
        try context.delete(model: type)
        try context.save()
    }
    
    func delete<T: PersistentModel>(_ type: T.Type, for deletionPredicate: Predicate<T>) throws {
        guard let modelContainer = modelContainer else {
            print("modelContainer is nil when trying to delete a model")
            return
        }
        
        let context = ModelContext(modelContainer)
        try context.delete(model: type, where: deletionPredicate)
        try context.save()
    }
}

struct Firebase: Database {
    var playersListener: ListenerRegistration!
    var gameListener: ListenerRegistration!
    var teamsListener: ListenerRegistration!
    var modelContainer: ModelContainer?
    private var db = Firestore.firestore()
    private var docRef: DocumentReference?
    
    var startTime: Date
    
    init(useInMemoryStore: Bool = false) {
        do {
            startTime = .now
            let configuration = ModelConfiguration(for: GameModel.self, isStoredInMemoryOnly: useInMemoryStore)
            modelContainer = try ModelContainer(for: GameModel.self, migrationPlan: GameModelsMigrationPlan.self, configurations: configuration)
            
            try create(GameModel(startTime: startTime))
        } catch {
            print("error        tried to initialize Firebase() \n\(error)\n")
        }
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
    
    mutating func setDocRef(_ groupId: Int) {
        docRef = db.collection("games").document("\(groupId)")
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
    
    func setInitTeamState(_ teamState: TeamState, _ teamNum: Int) throws {
        try docRef!.collection("teams").document("\(teamNum)").setData(from: teamState)
    }
    
    func getTeamState(_ teamNum: Int) async throws -> TeamState {
        guard let docRef = docRef else {
            return TeamState()
        }
        
        return try await docRef.collection("teams").document("\(teamNum)").getDocument().data(as: TeamState.self)
    }
    
    func setInitPlayerState(_ playerState: PlayerState, _ playerUid: String) throws {
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
    var modelContainer: ModelContainer?
    var startTime: Date
    
    init(useInMemoryStore: Bool = true) {
        do {
            startTime = .now
            
            let configuration = ModelConfiguration(for: GameModel.self, isStoredInMemoryOnly: useInMemoryStore)
            modelContainer = try ModelContainer(for: GameModel.self, configurations: configuration)
            
            try create(GameModel(startTime: startTime))
        } catch {
            print("error        tried to initialize Local() \n\(error)\n")
        }
    }
    
    func updatePlayerField<T>(uid: String, key: String, value: T) async throws {
        let tempGameModel = GameModel(startTime: self.startTime)
        
        if tempGameModel.playerState != nil && tempGameModel.playerState!.uid == uid {
            tempGameModel.playerState![key] = value
        } else if let idx = tempGameModel.players.firstIndex(where: { $0.uid == uid }) {
            tempGameModel.players[idx][key] = value
        }
        
        try update(tempGameModel)
    }
    
    func updatePlayerArrayField<T: Equatable>(uid: String, key: String, value: [T], action: ArrayActionType) async throws {
        let tempGameModel = GameModel(startTime: self.startTime)

        if tempGameModel.playerState != nil && tempGameModel.playerState!.uid == uid {
            switch action {
                case .append:
                    var tempAttribute: [T] = tempGameModel.playerState![key] as! [T]
                    
                    tempAttribute.append(contentsOf: value)
                    tempGameModel.playerState![key] = tempAttribute
                case .remove:
                    var tempAttribute: [T] = tempGameModel.playerState![key] as! [T]
                    
                    for val in value {
                        tempAttribute.removeAll(where: {
                            $0 == val
                        })
                    }
                    tempGameModel.playerState![key] = tempAttribute
                case .replace:
                    tempGameModel.playerState![key] = value
            }
        } else if let idx = tempGameModel.players.firstIndex(where: { $0.uid == uid }) {
            switch action {
                case .append:
                    var tempAttribute: [T] = tempGameModel.players[idx][key] as! [T]
                    
                    tempAttribute.append(contentsOf: value)
                    tempGameModel.players[idx][key] = tempAttribute
                case .remove:
                    var tempAttribute: [T] = tempGameModel.players[idx][key] as! [T]
                    
                    for val in value {
                        tempAttribute.removeAll(where: {
                            $0 == val
                        })
                    }
                    tempGameModel.players[idx][key] = tempAttribute
                case .replace:
                    tempGameModel.players[idx][key] = value
            }
        }
        
        try update(tempGameModel)
    }
    
    func updateGameField<T>(key: String, value: T) async throws {
        let tempGameModel = GameModel(startTime: self.startTime)
        tempGameModel.gameState![key] = value
        try update(tempGameModel)
    }
    
    func updateGameArrayField<T: Equatable>(key: String, value: [T], action: ArrayActionType) async throws {
        let tempGameModel = GameModel(startTime: self.startTime)
        
        if tempGameModel.gameState != nil {
            switch action {
                case .append:
                    var tempAttribute: [T] = tempGameModel.gameState![key] as! [T]
                    
                    tempAttribute.append(contentsOf: value)
                    tempGameModel.gameState![key] = tempAttribute
                case .remove:
                    var tempAttribute: [T] = tempGameModel.gameState![key] as! [T]
                    
                    for val in value {
                        tempAttribute.removeAll(where: {
                            $0 == val
                        })
                    }
                    tempGameModel.gameState![key] = tempAttribute
                case .replace:
                    tempGameModel.gameState![key] = value
            }
        }
        
        try update(tempGameModel)
    }
    
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws {
        let tempGameModel = GameModel(startTime: self.startTime)

        if tempGameModel.teamState != nil && tempGameModel.teamState!.team_num == teamNum {
            tempGameModel.teamState![key] = value
        } else if let idx = tempGameModel.teams.firstIndex(where: { $0.team_num == teamNum }) {
            tempGameModel.teams[idx][key] = value
        }

        try update(tempGameModel)
    }
    
    func setDocRef(_ groupId: Int) { /* don't need this function */ }
    
    func setInitGameState(_ gameState: GameState) throws {
        let tempGameModel = GameModel(startTime: self.startTime)
        tempGameModel.gameState = gameState
        try update(tempGameModel)
    }
    
    func getGameState() async throws -> GameState {
        if let gameModel = try read( #Predicate<GameModel> { model in
            model.startTime == startTime
        }).first {
            if let gameState = gameModel.gameState {
                return gameState
            } else {
                print("error        couldn't find gameState in getGameState()")
                return GameState()
            }
        } else {
            print("error        couldn't find gameModel in getGameState()")
            return GameState()
        }
    }
    
    func getGameState(_ groupId: Int) async throws -> GameState {
        /* don't need this function */
        return GameState()
    }
    
    func setInitTeamState(_ teamState: TeamState, _ teamNum: Int) throws {
        let tempGameModel = GameModel(startTime: self.startTime)
        tempGameModel.teamState = teamState
        try update(tempGameModel)
    }
    
    func getTeamState(_ teamNum: Int) async throws -> TeamState {
        guard let gameModel = try read( #Predicate<GameModel> { model in
            model.startTime == startTime
        }).first else {
            return TeamState()
        }
        
        guard let teamState = gameModel.teamState else {
            return TeamState()
        }
        
        if teamState.team_num == teamNum {
            return teamState
        } else if let idx = gameModel.teams.firstIndex(where: { $0.team_num == teamNum }) {
            return gameModel.teams[idx]
        } else {
            return TeamState()
        }
    }
    
    func setInitPlayerState(_ playerState: PlayerState, _ playerUid: String) throws {
        let tempGameModel = GameModel(startTime: self.startTime)
        tempGameModel.playerState = playerState
        try update(tempGameModel)
    }
    
    func addPlayersListener(_ playerStateRef: Reference<PlayerState>, _ playersRef: Reference<[PlayerState]>) async {
        /* don't need this function */
    }
    
    func removePlayersListener() {
        /* don't need this function */
    }
    
    func addGameStateListener(_ gameStateRef: Reference<GameState>) async {
        
    }
    
    func updateGameStateRef(_ gameStateRef: Reference<GameState>) async {
        
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

struct NilDB: Database {
    var modelContainer: ModelContainer?

    func updatePlayerField<T>(uid: String, key: String, value: T) async throws {
        // not needed
    }
    
    func updatePlayerArrayField<T>(uid: String, key: String, value: [T], action: ArrayActionType) async throws where T: Equatable {
        // not needed
    }
    
    func updateGameField<T>(key: String, value: T) async throws {
        // not needed
    }
    
    func updateGameArrayField<T>(key: String, value: [T], action: ArrayActionType) async throws where T: Equatable {
        // not needed
    }
    
    func updateTeamField<T>(teamNum: Int, key: String, value: T) async throws {
        // not needed
    }
    
    mutating func setDocRef(_ groupId: Int) {
        // not needed
    }
    
    func setInitGameState(_ gameState: GameState) throws {
        // not needed
    }
    
    func getGameState() async throws -> GameState {
        // not needed
        return GameState() // Assuming GameState has a default initializer
    }
    
    func getGameState(_ groupId: Int) async throws -> GameState {
        // not needed
        return GameState() // Assuming GameState has a default initializer
    }
    
    func setInitTeamState(_ teamState: TeamState, _ teamNum: Int) throws {
        // not needed
    }
    
    func getTeamState(_ teamNum: Int) async throws -> TeamState {
        // not needed
        return TeamState() // Assuming TeamState has a default initializer
    }
    
    func setInitPlayerState(_ playerState: PlayerState, _ playerUid: String) throws {
        // not needed
    }
    
    mutating func addPlayersListener(_ playerStateRef: Reference<PlayerState>, _ playersRef: Reference<[PlayerState]>) async {
        // not needed
    }
    
    mutating func removePlayersListener() {
        // not needed
    }
    
    mutating func addGameStateListener(_ gameStateRef: Reference<GameState>) async {
        // not needed
    }
    
    mutating func removeGameStateListener() {
        // not needed
    }
    
    mutating func addTeamsListener(_ teamStateRef: Reference<TeamState>, _ teamsRef: Reference<[TeamState]>) async {
        // not needed
    }
    
    mutating func removeTeamsListener() {
        // not needed
    }
    
    func checkGameExists(groupId: Int) async throws -> Bool {
        // not needed
        return false
    }
    
    func checkTeamExists(teamNum: Int) async throws -> Bool {
        // not needed
        return false
    }
    
    func deleteGameCollection(id: Int) async {
        // not needed
    }
    
    func deleteTeamCollection(teamNum: Int) async throws {
        // not needed
    }
}
