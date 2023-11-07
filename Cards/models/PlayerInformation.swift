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
    var name: String = ""
    var uid: String = ""
    var cards_in_hand: [CardItem] = []
    var is_lead: Bool = false
    var team_num: Int = 0
    var is_ready: Bool = false

    static var player_one = PlayerInformation(name: "Daniel", uid: "001", cards_in_hand: [CardItem(id: 0, value: "J", suit: "D"), CardItem(id: 1, value: "9", suit: "H"), CardItem(id: 2, value: "6", suit: "S"), CardItem(id: 3, value: "9", suit: "S")], is_lead: true, team_num: 1)
    static var player_two = PlayerInformation(name: "Katie", uid: "002", cards_in_hand: [CardItem(id: 0, value: "5", suit: "H"), CardItem(id: 1, value: "5", suit: "D"), CardItem(id: 2, value: "5", suit: "S"), CardItem(id: 3, value: "J", suit: "S")], is_lead: false, team_num: 2)
    
    enum CodingKeys: CodingKey {
        case name
        case uid
        case cards_in_hand
        case is_lead
        case team_num
        case is_ready
    }
}
