//
//  GameInformation.swift
//  Cards
//
//  Created by Daniel Wells on 10/20/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore


public struct GameInformation: Hashable, Codable {
    var group_id: Int = 0
    var is_ready: Bool = false
    var is_won: Bool = false
    var num_players: Int = 0
    var turn: Int = 0
    var count_points: Int = 0
    var cards: [CardItem] = [
        CardItem(id: 0, value: "A", suit: "S"),
        CardItem(id: 1, value: "2", suit: "S"),
        CardItem(id: 2, value: "3", suit: "S"),
        CardItem(id: 3, value: "4", suit: "S"),
        CardItem(id: 4, value: "5", suit: "S"),
        CardItem(id: 5, value: "6", suit: "S"),
        CardItem(id: 6, value: "7", suit: "S"),
        CardItem(id: 7, value: "8", suit: "S"),
        CardItem(id: 8, value: "9", suit: "S"),
        CardItem(id: 9, value: "10", suit: "S"),
        CardItem(id: 10, value: "J", suit: "S"),
        CardItem(id: 11, value: "Q", suit: "S"),
        CardItem(id: 12, value: "K", suit: "S"),
        CardItem(id: 13, value: "A", suit: "H"),
        CardItem(id: 14, value: "2", suit: "H"),
        CardItem(id: 15, value: "3", suit: "H"),
        CardItem(id: 16, value: "4", suit: "H"),
        CardItem(id: 17, value: "5", suit: "H"),
        CardItem(id: 18, value: "6", suit: "H"),
        CardItem(id: 19, value: "7", suit: "H"),
        CardItem(id: 20, value: "8", suit: "H"),
        CardItem(id: 21, value: "9", suit: "H"),
        CardItem(id: 22, value: "10", suit: "H"),
        CardItem(id: 23, value: "J", suit: "H"),
        CardItem(id: 24, value: "Q", suit: "H"),
        CardItem(id: 25, value: "K", suit: "H"),
        CardItem(id: 26, value: "A", suit: "D"),
        CardItem(id: 27, value: "2", suit: "D"),
        CardItem(id: 28, value: "3", suit: "D"),
        CardItem(id: 29, value: "4", suit: "D"),
        CardItem(id: 30, value: "5", suit: "D"),
        CardItem(id: 31, value: "6", suit: "D"),
        CardItem(id: 32, value: "7", suit: "D"),
        CardItem(id: 33, value: "8", suit: "D"),
        CardItem(id: 34, value: "9", suit: "D"),
        CardItem(id: 35, value: "10", suit: "D"),
        CardItem(id: 36, value: "J", suit: "D"),
        CardItem(id: 37, value: "Q", suit: "D"),
        CardItem(id: 38, value: "K", suit: "D"),
        CardItem(id: 39, value: "A", suit: "C"),
        CardItem(id: 40, value: "2", suit: "C"),
        CardItem(id: 41, value: "3", suit: "C"),
        CardItem(id: 42, value: "4", suit: "C"),
        CardItem(id: 43, value: "5", suit: "C"),
        CardItem(id: 44, value: "6", suit: "C"),
        CardItem(id: 45, value: "7", suit: "C"),
        CardItem(id: 46, value: "8", suit: "C"),
        CardItem(id: 47, value: "9", suit: "C"),
        CardItem(id: 48, value: "10", suit: "C"),
        CardItem(id: 49, value: "J", suit: "C"),
        CardItem(id: 50, value: "Q", suit: "C"),
        CardItem(id: 51, value: "K", suit: "C")
    ]
}
