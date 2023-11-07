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
}
