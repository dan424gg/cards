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
    var name: String = ""
    var uid: String = ""
    var cards_in_hand: [Int] = []
    var is_lead: Bool = false
    var team_num: Int = 0
    var is_ready: Bool = false
    var player_num: Int = -1
    var cards_dragged: [Int] = []
    
    var callouts: [String] = []

    static var player_one = PlayerState(name: "Daniel", uid: "1", cards_in_hand: Array(5...8), is_lead: true, team_num: 1, is_ready: true, player_num: 0, cards_dragged: Array(5...8), callouts: ["15 for 2!", "Run of 3 for 5!", "Flush for 9!"])
    static var player_two = PlayerState(name: "Katie", uid: "2", cards_in_hand: Array(9...12), is_lead: false, team_num: 2, player_num: 1, cards_dragged: Array(9...12), callouts: ["15 for 2!", "Run of 3 for 5!", "Flush for 9!"])
    static var player_three = PlayerState(name: "Ben", uid: "3", cards_in_hand: Array(13...16), is_lead: false, team_num: 3, is_ready: true, player_num: 2, cards_dragged: Array(13...16), callouts: ["15 for 2!", "Run of 3 for 5!", "Flush for 9!"])
    static var player_four = PlayerState(name: "Alex", uid: "4", cards_in_hand: Array(17...20), is_lead: false, team_num: 1, is_ready: true, player_num: 3, cards_dragged: Array(17...20), callouts: ["15 for 2!", "Run of 3 for 5!", "Flush for 9!"])
    static var player_five = PlayerState(name: "Ryan", uid: "5", cards_in_hand: Array(21...24), is_lead: false, team_num: 2, player_num: 4, cards_dragged: Array(21...24), callouts: ["15 for 2!", "Run of 3 for 5!", "Flush for 9!"])
    static var player_six = PlayerState(name: "Nitant", uid: "6", cards_in_hand: Array(25...28), is_lead: false, team_num: 3, is_ready: true,  player_num: 5, cards_dragged: Array(25...28), callouts: ["15 for 2!", "Run of 3 for 5!", "Flush for 9!"])
    
    enum CodingKeys: CodingKey {
        case name
        case uid
        case cards_in_hand
        case is_lead
        case team_num
        case is_ready
        case player_num
        case cards_dragged
        case callouts
    }
}

extension PlayerState {
    subscript(_ keyPath: String) -> Any? {
        get {
            if let data = try? JSONEncoder().encode(self)
                , var dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] { //Any of this could fail silently at any time
                return dict[keyPath]
            } else {
                return nil
            }
        }
        set {
            if let data = try? JSONEncoder().encode(self)
                , var dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] { //Any of this could fail silently at any time
                dict[keyPath] = newValue
                
                if let newData = try? JSONSerialization.data(withJSONObject: dict), let newObj = try? JSONDecoder().decode(Self.self, from: newData) { //Any of this could fail silently at any time
                    self = newObj
                }
            }
        }
    }
}
