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
    var color: String = "White"
    
    static let team_one = TeamState(team_num: 1, points: 50, color: "Red")
    static let team_two = TeamState(team_num: 2, points: 46, color: "Blue")
    static let team_three = TeamState(team_num: 3, points: 73, color: "Orange")
    
    enum CodingKeys: String, CodingKey {
        case team_num
        case points
        case color
    }
}

extension TeamState {
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

public class TeamObservable: ObservableObject {
    @Published var team: TeamState

    init(team: TeamState) {
        self.team = team
    }
}
