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
    
    func howManyPoints(cardsInCount: Binding<[CardItem]>) -> Int {
        var points = 0
        var running_total = 0
        var cards = cardsInCount.wrappedValue
        
        if cards.count == 2 {
            if cards[0].value == cards[1].value { points += 2 }
            if cards[0].point_value + cards[1].point_value == 15 { points += 2 }
        } else if cards.count > 2 {
            if cards[0].value == cards[1].value && cards[0].value == cards[2].value { points += 6 }
        }
        
        return points
    }
    
}
