//
//  TeamInformation.swift
//  Cards
//
//  Created by Daniel Wells on 10/21/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore


public struct TeamInformation: Hashable, Codable {
    var team_num: Int = 1
    var crib: [CardItem] = []
    var has_crib: Bool = false
    var points: Int = 0
    
    static let team_one = TeamInformation(team_num: 1, crib: [CardItem(id: 0, value: "A", suit: "H"), CardItem(id: 1, value: "5", suit: "H"), CardItem(id: 2, value: "4", suit: "S"), CardItem(id: 3, value: "K", suit: "H")], has_crib: true, points: 50)
    static let team_two = TeamInformation(team_num: 2, crib: [], has_crib: false, points: 46)

//    enum CodingKeys: String, CodingKey {
//        case crib
//        case has_crib
//        case players_on_team
//        case points
//    }
}
