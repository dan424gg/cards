//
//  GameState.swift
//  Cards
//
//  Created by Daniel Wells on 10/20/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore

public struct GameState: Hashable, Codable {
    var group_id: Int = 0
    var is_playing: Bool = false
    var is_won: Bool = false
    var num_teams: Int = 0
    var turn: Int = 1
    var game_name: String = ""
    var num_players: Int = 0
    var dealer: Int = -1
    var team_with_crib: Int = 0
    var crib: [Int] = []
    var cards: [Int] = Array(0...51) // array containing int that reference a playing card
    var starter_card: Int = -1
    var colors_available: [String] = ["Red", "Blue", "Teal", "Green", "Yellow", "Orange"]
    var player_turn: Int = -1
    
    // used during "The Play"
    var play_cards: [Int] = []
    var running_sum: Int = 0
    var num_go: Int = 0
    
    static var game: GameState = GameState(group_id: 1234, is_playing: true, num_teams: 3, turn: 3, game_name: "cribbage", num_players: 3, dealer: 0, team_with_crib: 1, crib: Array(0...3), cards: GameState().cards.shuffled(), starter_card: 19, player_turn: 0)
    
    enum CodingKeys: CodingKey {
        case group_id
        case is_playing
        case is_won
        case num_teams
        case turn
        case game_name
        case num_players
        case dealer
        case team_with_crib
        case crib
        case cards
        case starter_card
        case colors_available
        case player_turn
        case play_cards
        case running_sum
        case num_go
    }
}

public class GameObservable: ObservableObject {
    @Published var game: GameState

    init(game: GameState) {
        self.game = game
    }
}
