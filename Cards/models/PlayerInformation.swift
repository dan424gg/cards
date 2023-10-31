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
    var name: String
    var uid: String
    var player_num: Int
    var cards_in_hand: [CardItem]
    var is_lead: Bool
    var team_num: Int
    var is_ready: Bool = false

    static let player_one = PlayerInformation(name: "Daniel", uid: "001", player_num: 0, cards_in_hand: [CardItem(id: 0, card: "DJ"), CardItem(id: 1, card: "D9"), CardItem(id: 2, card: "S6"), CardItem(id: 3, card: "H6")], is_lead: true, team_num: 1)
    static let player_two = PlayerInformation(name: "Katie", uid: "002", player_num: 1, cards_in_hand: [CardItem(id: 0, card: "H5"), CardItem(id: 1, card: "D5"), CardItem(id: 2, card: "S5"), CardItem(id: 3, card: "HJ")], is_lead: false, team_num: 2)
    
//    enum CodingKeys: String, CodingKey {
//        case name
//        case player_num
//        case cards_in_hand
//        case is_lead
//        case team_num
//    }
}
