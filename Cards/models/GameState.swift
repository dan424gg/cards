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
    var turn: Int = 0
    var game_name: String = ""
    var num_players: Int = 0
    var dealer: Int = -1
    var team_with_crib: Int = 0
    var crib: [Int] = []
    var cards: [Int] = Array(0...51) // array containing int to reference to corresponding card
}
