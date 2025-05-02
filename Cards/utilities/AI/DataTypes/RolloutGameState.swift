//
//  RolloutGameState.swift
//  Cards
//
//  Created by Daniel Wells on 9/3/24.
//

import Foundation

class RolloutGameState {
    var deck: [CardItem]
    var playerOneHand: [CardItem]
    var playerTwoHand: [CardItem]
    var playCards: [CardItem]
    
    var scoreOne: Int
    var scoreTwo: Int
    
    var currentPlayer: Int
    var firstPlayer: Int
    
    init(deck: [Int], playerOneHand: [Int], playerTwoHand: [Int], playCards: [Int], scoreOne: Int, scoreTwo: Int, currentPlayer: Int, firstPlayer: Int) {
        self.deck = convertToCardItem(hand: deck)
        self.playerOneHand = convertToCardItem(hand: playerOneHand)
        self.playerTwoHand = convertToCardItem(hand: playerTwoHand)
        self.playCards = convertToCardItem(hand: playCards)
        self.scoreOne = scoreOne
        self.scoreTwo = scoreTwo
        self.currentPlayer = currentPlayer
        self.firstPlayer = firstPlayer
    }
    
    init(_ gamehelper: nonMainActorGameHelper) {
        self.deck = convertToCardItem(hand: gamehelper.gameState.cards)
        
        gamehelper.players.sort(by: { $0.player_num < $1.player_num })
        self.playerOneHand = convertToCardItem(hand: gamehelper.players[0].cards_in_hand)
        self.playerTwoHand = []
        self.playCards = convertToCardItem(hand: gamehelper.gameState.play_cards)
        
        gamehelper.teams.sort(by: { $0.team_num < $1.team_num })
        self.scoreOne = gamehelper.teams[0].points
        self.scoreTwo = gamehelper.teams[1].points
        self.currentPlayer = gamehelper.gameState.player_turn
        self.firstPlayer = gamehelper.gameState.player_turn
    }
    
    func copy() -> RolloutGameState {
        return RolloutGameState(deck: convertToInts(hand: deck), playerOneHand: convertToInts(hand: playerOneHand), playerTwoHand: convertToInts(hand: playerTwoHand), playCards: convertToInts(hand: playCards), scoreOne: scoreOne, scoreTwo: scoreTwo, currentPlayer: currentPlayer, firstPlayer: firstPlayer)
    }
    
    func isTerminalState() -> Bool {
        return playerOneHand.count == 0 && playerTwoHand.count == 0
    }
    
    func getValidMoves(playerTurn: Int) -> [CardItem] {
        var hand: [CardItem] {
            if playerTurn == 1 {
                return playerOneHand
            } else {
                return playerTwoHand
            }
        }
        
        var currentCount: Int {
            if playCards.count > 0 {
                var currentCount_aux: Int = 0
                
                for card in playCards {
                    currentCount_aux += card.card.pointValue
                }
                
                return currentCount_aux
            } else {
                return 0
            }
        }
        
        let validMoves = hand.filter {
            $0.card.pointValue + currentCount <= 31
        }
        
        return validMoves
    }
    
    func applyMove(move: CardItem) {
        if currentPlayer == 1 {
            playerOneHand.removeAll(where: { $0.id == move.id })
        } else {
            playerTwoHand.removeAll(where: { $0.id == move.id })
        }
        
        playCards.append(move)
        
        updateScores()
        
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
    }
    
    func updateScores() {
        
        func checkForSum(_ array: [Int], _ targetValue: Int, _ scoringHands: inout [ScoringHand], _ points: inout Int) {
            
            func findCombinations(_ startIndex: Int, _ currentSum: Int, _ cardsInCombination: [Int]) {
                if currentSum == targetValue {
                    points = points + 2
                    scoringHands.append(ScoringHand(scoreType: .sum, cumlativePoints: points, cardsInScoredHand: cardsInCombination, pointsCallOut: "15 for \(points)!"))
                    return
                }
                
                if currentSum > targetValue || startIndex >= array.count {
                    return
                }
                
                for i in startIndex..<array.count {
                    findCombinations(i + 1, currentSum + CardItem(id: array[i]).card.pointValue, cardsInCombination + [array[i]])
                }
            }
            
            findCombinations(0, 0, [] as! [Int])
        }
        
        func checkForRun(_ cards: [Int]) -> Int {
            guard cards.count > 2 else {
                return 0
            }
            
            var maxNumOfCardsInRun = 0
            
            for i in 3...cards.count {
                var numOfCardsInRun = 1
                let runOfCards = Array(cards.suffix(i).sorted(by: { CardItem(id: $0) < CardItem(id: $1) }))
                
                for c in 1..<runOfCards.count {
                    let firstCard = runOfCards[c - 1] % 13
                    let secondCard = runOfCards[c] % 13

                    if (secondCard - firstCard != 1) {
                        numOfCardsInRun = 1
                        break
                    } else {
                        numOfCardsInRun += 1
                    }
                }
                
                maxNumOfCardsInRun = max(numOfCardsInRun, maxNumOfCardsInRun)
            }
            return maxNumOfCardsInRun > 2 ? maxNumOfCardsInRun : 0
        }
        
        func checkForSets(_ cards: [Int], _ scoringHands: inout [ScoringHand], _ points: inout Int) {
            let sortedCards = cards.sorted(by: { $0 < $1 })
            var counts: [Int : [Int]] = [:]
            
            sortedCards.forEach { card in
                counts[card % 13, default: []] += [card]
            }
            
            for (_, value) in counts {
                if value.count == 2 {
                    points = points + 2
                    scoringHands.append(ScoringHand(scoreType: .set, cumlativePoints: points, cardsInScoredHand: value, pointsCallOut: "Pair for \(points)!"))
                } else if value.count == 3 {
                    points = points + 6
                    scoringHands.append(ScoringHand(scoreType: .set, cumlativePoints: points, cardsInScoredHand: value, pointsCallOut: "Pair royal for \(points)!"))
                } else if value.count == 4 {
                    points = points + 12
                    scoringHands.append(ScoringHand(scoreType: .set, cumlativePoints: points, cardsInScoredHand: value, pointsCallOut: "Double pair royal for \(points)!"))
                }
            }
        }
        
        func checkPlayCardsForPoints(cards: [Int]) -> Int {
            guard !cards.isEmpty else {
                return -10000
            }
            
            var points: Int = 0
            var scoringPlays: [ScoringHand] = []

            checkForSum(cards, 15, &scoringPlays, &points)
            checkForSum(cards, 31, &scoringPlays, &points)
            points += checkForRun(cards)
            checkForSets(cards, &scoringPlays, &points)
                    
            return points
        }
        
        if currentPlayer == 1 {
            scoreOne += checkPlayCardsForPoints(cards: convertToInts(hand: playCards))
        } else {
            scoreTwo += checkPlayCardsForPoints(cards: convertToInts(hand: playCards))
        }
    }
    
    func evaluate() -> Int {
        if firstPlayer == 1 {
            return scoreOne - scoreTwo
        } else {
            return scoreTwo - scoreOne
        }
    }
}
