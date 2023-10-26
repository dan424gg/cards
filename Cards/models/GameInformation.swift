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
    var group_id: Int
    var is_pregame: Bool
    var is_won: Bool
    var num_players: Int
    var turn: Int

//    enum CodingKeys: String, CodingKey {
//        case group_id
//        case is_pregame
//        case is_won
//        case num_players
//        case turn
//    }
}
