//
//  CribbageState.swift
//  Cards
//
//  Created by Daniel Wells on 11/3/23.
//

import Foundation
import SwiftUI

class CribbageController: FirebaseHelper {
    func readyPlayer(cardsDragged: Binding<[CardItem]>) -> Bool {
        switch (gameInfo!.turn) {
        case 1:
            if gameInfo!.num_teams == 2 {
                return true
            }
//        case 2:
//        case 3:
//        case 4:
        default: return false
        }
        return false
    }
    
    func determineDealer(numPlayers: Int) -> Int {
        return Int.random(in: 1..<(numPlayers + 1))
    }

    func calculateCribbagePoints(cardPlayed: CardItem, previousCards: [CardItem]) -> Int {
        var totalPoints = 0
        
        // find fifteens
        // find sequences of 3 or more
        // find pairs, trips, or quads

        // Cribbage scoring rules

        // Fifteen: 2 points for each combination of cards that sums to 15.
        var combinations: [[CardItem]] = []

        func findCombinations(currentCombination: [CardItem], remainingCards: [CardItem], targetSum: Int) {
            let currentSum = currentCombination.reduce(0) { $0 + $1.point_value }
            
            if currentSum == targetSum {
                combinations.append(currentCombination)
            } else if currentSum < targetSum {
                for (index, card) in remainingCards.enumerated() {
                    var newRemainingCards = remainingCards
                    newRemainingCards.remove(at: index)
                    findCombinations(currentCombination: currentCombination + [card], remainingCards: newRemainingCards, targetSum: targetSum)
                }
            }
        }

        for (index, card) in previousCards.enumerated() {
            findCombinations(currentCombination: [card], remainingCards: Array(previousCards[(index + 1)...]), targetSum: 15)
        }

        totalPoints += combinations.count * 2

        // Pairs: 2 points for each pair of cards with the same rank.
        for (index, card1) in previousCards.enumerated() {
            for card2 in previousCards[(index + 1)...] where card1.value == card2.value {
                totalPoints += 2
            }
        }

        // Runs: 1 point for each card in a sequence of three or more consecutive cards.
        var sortedCards = previousCards + [cardPlayed]
        sortedCards.sort { $0.point_value < $1.point_value }
        var currentRunLength = 1

        for (index, card) in sortedCards.enumerated() {
            if index > 0, card.point_value == sortedCards[index - 1].point_value + 1 {
                currentRunLength += 1
            } else {
                if currentRunLength >= 3 {
                    totalPoints += currentRunLength
                }
                currentRunLength = 1
            }
        }

        return totalPoints
    }
}
