//
//  GameInformation.swift
//  Cards
//
//  Created by Daniel Wells on 10/16/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore


public struct PlayerInformation: Hashable, Codable {
    var name: String? = ""
    var uid: String? = ""
    var cards_in_hand: [CardItem]? = []
    var is_lead: Bool? = false
    var team_num: Int? = 0
    var is_ready: Bool? = false
    var is_dealer: Bool? = false
    var player_num: Int? = -1

    static var player_one = PlayerInformation(name: "Daniel", uid: "001", cards_in_hand: [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")], is_lead: true, team_num: 1, player_num: 1)
    static var player_two = PlayerInformation(name: "Katie", uid: "002", cards_in_hand: [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")], is_lead: false, team_num: 2, player_num: 2)
    static var player_three = PlayerInformation(name: "Ben", uid: "001", cards_in_hand: [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")], is_lead: true, team_num: 1, player_num: 3)
    static var player_four = PlayerInformation(name: "Alex", uid: "002", cards_in_hand: [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")], is_lead: false, team_num: 2, player_num: 4)
    
    enum CodingKeys: CodingKey {
        case name
        case uid
        case cards_in_hand
        case is_lead
        case team_num
        case is_ready
        case is_dealer
        case player_num
    }
}
