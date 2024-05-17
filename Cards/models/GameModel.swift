//
//  GameModel.swift
//  Cards
//
//  Created by Daniel Wells on 5/17/24.
//

import Foundation
import SwiftData

@Model
final class GameModel: Codable {
    var inProgress: Bool
    
    var gameState: GameState?
    var teamState: TeamState?
    var playerState: PlayerState?
    var players: [PlayerState]
    var teams: [TeamState]
    var gameOutcome: GameOutcome
    
    init(inProgress: Bool = true, gameState: GameState? = nil, teamState: TeamState? = nil, playerState: PlayerState? = nil, players: [PlayerState], teams: [TeamState], gameOutcome: GameOutcome) {
        self.inProgress = inProgress
        self.gameState = gameState
        self.teamState = teamState
        self.playerState = playerState
        self.players = players
        self.teams = teams
        self.gameOutcome = gameOutcome
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
