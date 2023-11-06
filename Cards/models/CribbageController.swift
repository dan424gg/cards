//
//  CribbageState.swift
//  Cards
//
//  Created by Daniel Wells on 11/3/23.
//

import Foundation
import SwiftUI

class CribbageController {
    
    func readyForNextRound(players: [PlayerInformation]) -> Bool {
        for player in players {
            if !player.is_ready {
                return false
            }
        }
        
        return true
    }
    
}
