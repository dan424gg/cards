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
    var team_num: Int
    var crib: [CardItem]
    var has_crib: Bool
    var points: Int
    
    static let team_one = TeamInformation(team_num: 1, crib: [CardItem(id: 0, card: "HA"), CardItem(id: 1, card: "H5"), CardItem(id: 2, card: "HJ"), CardItem(id: 3, card: "HK")], has_crib: true, points: 50)
    static let team_two = TeamInformation(team_num: 2, crib: [], has_crib: false, points: 46)

//    enum CodingKeys: String, CodingKey {
//        case crib
//        case has_crib
//        case players_on_team
//        case points
//    }
}
