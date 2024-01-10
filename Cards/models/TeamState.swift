//
//  TeamState.swift
//  Cards
//
//  Created by Daniel Wells on 10/21/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore


public struct TeamState: Hashable, Codable {
    var team_num: Int = 0
    var points: Int = 0
    
    static let team_one = TeamState(team_num: 1, points: 50)
    static let team_two = TeamState(team_num: 2, points: 46)
    static let team_three = TeamState(team_num: 3, points: 73)
    
//    enum CodingKeys: String, CodingKey {
//        case crib
//        case has_crib
//        case players_on_team
//        case points
//    }
}
