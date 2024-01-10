//
//  GameState.swift
//  Cards
//
//  Created by Daniel Wells on 10/16/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore


public struct PlayerState: Hashable, Codable {
    var name: String? = ""
    var uid: String? = ""
    var cards_in_hand: [Int]? = []
    var is_lead: Bool? = false
    var team_num: Int? = 0
    var is_ready: Bool? = false
    var player_num: Int? = -1

    static var player_one = PlayerState(name: "Daniel", uid: "1", cards_in_hand: Array(39...42), is_lead: true, team_num: 1, player_num: 0)
    static var player_two = PlayerState(name: "Katie", uid: "2", cards_in_hand: Array(35...38), is_lead: false, team_num: 2, player_num: 1)
    static var player_three = PlayerState(name: "Ben", uid: "3", cards_in_hand: Array(31...34), is_lead: false, team_num: 3, player_num: 2)
    static var player_four = PlayerState(name: "Alex", uid: "4", cards_in_hand: Array(27...30), is_lead: false, team_num: 2, player_num: 3)
    
    enum CodingKeys: CodingKey {
        case name
        case uid
        case cards_in_hand
        case is_lead
        case team_num
        case is_ready
        case player_num
    }
}
