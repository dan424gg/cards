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
    var team_num: Int = 1
    var crib: [Int] = []
    var has_crib: Bool = false
    var points: Int = 0
    
    static let team_one = TeamState(team_num: 1, crib: Array(0...4), has_crib: true, points: 50)
    static let team_two = TeamState(team_num: 2, crib: [], has_crib: false, points: 46)

//    enum CodingKeys: String, CodingKey {
//        case crib
//        case has_crib
//        case players_on_team
//        case points
//    }
}
