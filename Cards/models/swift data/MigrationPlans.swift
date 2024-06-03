//
//  MigrationPlans.swift
//  Cards
//
//  Created by Daniel Wells on 5/19/24.
//

import Foundation
import SwiftData

enum GameModelsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GameModelSchemaV1.self, GameModelSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: GameModelSchemaV1.self,
        toVersion: GameModelSchemaV2.self
    )
    
    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: GameModelSchemaV2.self,
        toVersion: GameModelSchemaV3.self
    )
}

enum GameModelSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        return [GameModel.self]
    }

    @Model
    final class GameModel: Codable {
        var inProgress: Bool
        
        var gameState: GameState?
        var teamState: TeamState?
        var playerState: PlayerState?
        var players: [PlayerState]
        var teams: [TeamState]
        var gameOutcome: GameOutcome
        
        init(startTime: Date) {
            self.inProgress = true
            self.gameState = nil
            self.teamState = nil
            self.playerState = nil
            self.players = []
            self.teams = []
            self.gameOutcome = .undetermined
        }
        
        enum CodingKeys: String, CodingKey {
            case inProgress
            case gameState
            case teamState
            case playerState
            case players
            case teams
            case gameOutcome
        }
            
        // Decodable conformance
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.inProgress = try container.decode(Bool.self, forKey: .inProgress)
            self.gameState = try container.decodeIfPresent(GameState.self, forKey: .gameState)
            self.teamState = try container.decodeIfPresent(TeamState.self, forKey: .teamState)
            self.playerState = try container.decodeIfPresent(PlayerState.self, forKey: .playerState)
            self.players = try container.decode([PlayerState].self, forKey: .players)
            self.teams = try container.decode([TeamState].self, forKey: .teams)
            self.gameOutcome = try container.decode(GameOutcome.self, forKey: .gameOutcome)
        }
        
        // Encodable conformance
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(inProgress, forKey: .inProgress)
            try container.encodeIfPresent(gameState, forKey: .gameState)
            try container.encodeIfPresent(teamState, forKey: .teamState)
            try container.encodeIfPresent(playerState, forKey: .playerState)
            try container.encode(players, forKey: .players)
            try container.encode(teams, forKey: .teams)
            try container.encode(gameOutcome, forKey: .gameOutcome)
        }
    }
}

enum GameModelSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 1)
    
    static var models: [any PersistentModel.Type] {
        return [GameModel.self]
    }

    @Model
    final class GameModel: Codable {
        var startTime: Date?
        var inProgress: Bool
        
        var gameState: GameState?
        var teamState: TeamState?
        var playerState: PlayerState?
        var players: [PlayerState]
        var teams: [TeamState]
        var gameOutcome: GameOutcome
        
        init(startTime: Date = .now) {
            self.startTime = startTime
            self.inProgress = true
            self.gameState = nil
            self.teamState = nil
            self.playerState = nil
            self.players = []
            self.teams = []
            self.gameOutcome = .undetermined
        }
        
        enum CodingKeys: String, CodingKey {
            case startTime
            case inProgress
            case gameState
            case teamState
            case playerState
            case players
            case teams
            case gameOutcome
        }
            
        // Decodable conformance
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.startTime = try container.decode(Date.self, forKey: .startTime)
            self.inProgress = try container.decode(Bool.self, forKey: .inProgress)
            self.gameState = try container.decodeIfPresent(GameState.self, forKey: .gameState)
            self.teamState = try container.decodeIfPresent(TeamState.self, forKey: .teamState)
            self.playerState = try container.decodeIfPresent(PlayerState.self, forKey: .playerState)
            self.players = try container.decode([PlayerState].self, forKey: .players)
            self.teams = try container.decode([TeamState].self, forKey: .teams)
            self.gameOutcome = try container.decode(GameOutcome.self, forKey: .gameOutcome)
        }
        
        // Encodable conformance
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(inProgress, forKey: .inProgress)
            try container.encodeIfPresent(gameState, forKey: .gameState)
            try container.encodeIfPresent(teamState, forKey: .teamState)
            try container.encodeIfPresent(playerState, forKey: .playerState)
            try container.encode(players, forKey: .players)
            try container.encode(teams, forKey: .teams)
            try container.encode(gameOutcome, forKey: .gameOutcome)
        }
    }
}

enum GameModelSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 2)
    
    static var models: [any PersistentModel.Type] {
        return [GameModel.self]
    }

    @Model
    final class GameModel: Codable {
        @Attribute(.unique) var startTime: Date?
        var inProgress: Bool
        
        var gameState: GameState?
        var teamState: TeamState?
        var playerState: PlayerState?
        var players: [PlayerState]
        var teams: [TeamState]
        var gameOutcome: GameOutcome
        
        init(startTime: Date = .now) {
            self.startTime = startTime
            self.inProgress = true
            self.gameState = nil
            self.teamState = nil
            self.playerState = nil
            self.players = []
            self.teams = []
            self.gameOutcome = .undetermined
        }
        
        enum CodingKeys: String, CodingKey {
            case startTime
            case inProgress
            case gameState
            case teamState
            case playerState
            case players
            case teams
            case gameOutcome
        }
            
        // Decodable conformance
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.startTime = try container.decode(Date.self, forKey: .startTime)
            self.inProgress = try container.decode(Bool.self, forKey: .inProgress)
            self.gameState = try container.decodeIfPresent(GameState.self, forKey: .gameState)
            self.teamState = try container.decodeIfPresent(TeamState.self, forKey: .teamState)
            self.playerState = try container.decodeIfPresent(PlayerState.self, forKey: .playerState)
            self.players = try container.decode([PlayerState].self, forKey: .players)
            self.teams = try container.decode([TeamState].self, forKey: .teams)
            self.gameOutcome = try container.decode(GameOutcome.self, forKey: .gameOutcome)
        }
        
        // Encodable conformance
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(inProgress, forKey: .inProgress)
            try container.encodeIfPresent(gameState, forKey: .gameState)
            try container.encodeIfPresent(teamState, forKey: .teamState)
            try container.encodeIfPresent(playerState, forKey: .playerState)
            try container.encode(players, forKey: .players)
            try container.encode(teams, forKey: .teams)
            try container.encode(gameOutcome, forKey: .gameOutcome)
        }
    }
}

