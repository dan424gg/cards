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
    var who_won: Int = -1
    var num_teams: Int = 0
    var turn: Int = -1
    var game_name: String = ""
    var num_players: Int = 0
    var dealer: Int = -1
    var team_with_crib: Int = -1
    var crib: [Int] = []
    var cards: [Int] = Array(0...51).shuffled().shuffled() // array containing int that reference a playing card
    var starter_card: Int = -1
    var colors_available: [String] = ["Red", "Blue", "Teal", "Green", "Yellow", "Orange"]
    var player_turn: Int = -1
    
    // used during "The Play"
    var play_cards: [Int] = []
    var num_cards_in_play: Int = 0
    var running_sum: Int = 0
    var num_go: Int = 0
    
    static var game: GameState = GameState(group_id: 1234, is_playing: false, num_teams: 3, turn: 2, game_name: "cribbage", num_players: 6, dealer: 1, team_with_crib: 1, crib: Array(0...3), cards: Array(29...51).shuffled(), starter_card: 4, player_turn: 0)
    static var players = [PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six]
    static var teams = [TeamState.team_one, TeamState.team_two, TeamState.team_three]
    
    enum CodingKeys: CodingKey {
        case group_id
        case is_playing
        case who_won
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
        case num_cards_in_play
    }
}

public class GameObservable: ObservableObject {
    @Published var game: GameState

    init(game: GameState) {
        self.game = game
    }
}
