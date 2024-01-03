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
    var cards: [CardItem] = [
        // Spades
        CardItem(id: 0, value: "A", suit: "spade"),
        CardItem(id: 1, value: "2", suit: "spade"),
        CardItem(id: 2, value: "3", suit: "spade"),
        CardItem(id: 3, value: "4", suit: "spade"),
        CardItem(id: 4, value: "5", suit: "spade"),
        CardItem(id: 5, value: "6", suit: "spade"),
        CardItem(id: 6, value: "7", suit: "spade"),
        CardItem(id: 7, value: "8", suit: "spade"),
        CardItem(id: 8, value: "9", suit: "spade"),
        CardItem(id: 9, value: "10", suit: "spade"),
        CardItem(id: 10, value: "J", suit: "spade"),
        CardItem(id: 11, value: "Q", suit: "spade"),
        CardItem(id: 12, value: "K", suit: "spade"),
        
        // Hearts
        CardItem(id: 13, value: "A", suit: "heart"),
        CardItem(id: 14, value: "2", suit: "heart"),
        CardItem(id: 15, value: "3", suit: "heart"),
        CardItem(id: 16, value: "4", suit: "heart"),
        CardItem(id: 17, value: "5", suit: "heart"),
        CardItem(id: 18, value: "6", suit: "heart"),
        CardItem(id: 19, value: "7", suit: "heart"),
        CardItem(id: 20, value: "8", suit: "heart"),
        CardItem(id: 21, value: "9", suit: "heart"),
        CardItem(id: 22, value: "10", suit: "heart"),
        CardItem(id: 23, value: "J", suit: "heart"),
        CardItem(id: 24, value: "Q", suit: "heart"),
        CardItem(id: 25, value: "K", suit: "heart"),
        
        // Diamonds
        CardItem(id: 26, value: "A", suit: "diamond"),
        CardItem(id: 27, value: "2", suit: "diamond"),
        CardItem(id: 28, value: "3", suit: "diamond"),
        CardItem(id: 29, value: "4", suit: "diamond"),
        CardItem(id: 30, value: "5", suit: "diamond"),
        CardItem(id: 31, value: "6", suit: "diamond"),
        CardItem(id: 32, value: "7", suit: "diamond"),
        CardItem(id: 33, value: "8", suit: "diamond"),
        CardItem(id: 34, value: "9", suit: "diamond"),
        CardItem(id: 35, value: "10", suit: "diamond"),
        CardItem(id: 36, value: "J", suit: "diamond"),
        CardItem(id: 37, value: "Q", suit: "diamond"),
        CardItem(id: 38, value: "K", suit: "diamond"),
        
        // Clubs
        CardItem(id: 39, value: "A", suit: "club"),
        CardItem(id: 40, value: "2", suit: "club"),
        CardItem(id: 41, value: "3", suit: "club"),
        CardItem(id: 42, value: "4", suit: "club"),
        CardItem(id: 43, value: "5", suit: "club"),
        CardItem(id: 44, value: "6", suit: "club"),
        CardItem(id: 45, value: "7", suit: "club"),
        CardItem(id: 46, value: "8", suit: "club"),
        CardItem(id: 47, value: "9", suit: "club"),
        CardItem(id: 48, value: "10", suit: "club"),
        CardItem(id: 49, value: "J", suit: "club"),
        CardItem(id: 50, value: "Q", suit: "club"),
        CardItem(id: 51, value: "K", suit: "club"),
    ]
}
