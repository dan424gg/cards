//
//  PlayerView.swift
//  Cards
//
//  Created by Daniel Wells on 1/27/24.
//

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    
    @Binding var cards: [Int]
    @Binding var player: PlayerState
    var index: Int
    var playerTurn: Int
    
    @State var cardsInHand: [Int] = []
    @State var startingRotation = 0
    @State var multiplier = 0
    @State var scoringPlays: [ScoringHand] = []
    
    var body: some View {
        if (firebaseHelper.gameState?.turn ?? 3 == 2)  {
            VStack(spacing: -45) {
                Text(player.name)
                    .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                TurnTwoView(cardsDragged: .constant(player.cards_dragged), cardsInHand: .constant([]), otherPlayer: true)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(x: 0.5, y: 0.5)
                    .frame(width: 50, height: 125)
            }
            .offset(y: -145)
        } else if (firebaseHelper.gameState?.turn ?? 2 == 3) {
            if (firebaseHelper.gameState?.player_turn ?? playerTurn == player.player_num) {
                VStack {
                    DisplayPlayersHandContainer(player: player, visibilityFor: 3.0, scoringPlays: scoringPlays)
                    Text(player.name)
                        .font(.title3)
                        .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                }
                .rotationEffect(.degrees(180))
                .scaleEffect(x: 0.75, y: 0.75)
                .offset(y: -145)
                .frame(width: 200, height: 125)
            } else {
                VStack(spacing: -45) {
                    Text(player.name)
                        .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                    CardInHandArea(cardsDragged: .constant([]), cardsInHand: $cardsInHand, showBackside: player.player_num > firebaseHelper.gameState?.player_turn ?? playerTurn)
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: 0.25, y: 0.25)
                        .frame(width: 50, height: 125)
                        .onChange(of: player.cards_in_hand, initial: true, { (old, new) in
                            // check if a card was removed, run animation
                            if old.count > new.count {
                                let diff = old.filter { !new.contains($0) }
                                var temp = diff
                                
                                for i in 0..<diff.count {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(i)), execute: {
                                        withAnimation {
                                            cardsInHand.removeAll(where: {
                                                $0 == temp.first
                                            })
                                            cards.append(temp.removeFirst())
                                        }
                                    })
                                }
                            } else { // card was added
                                let diff = new.filter { !old.contains($0) }
                                var temp = diff
                                
                                for i in 0..<diff.count {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(i)), execute: {
                                        withAnimation {
                                            cards.removeAll(where: {
                                                $0 == temp.first
                                            })
                                            cardsInHand.append(temp.removeFirst())
                                        }
                                    })
                                }
                            }
                        })
                }
                .offset(y: -145)
            }
        } else {
            VStack(spacing: -45) {
                Text(player.name)
                    .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                CardInHandArea(cardsDragged: .constant([]), cardsInHand: $cardsInHand, showBackside: true)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(x: 0.25, y: 0.25)
                    .frame(width: 50, height: 125)
                    .onChange(of: player.cards_in_hand, initial: true, { (old, new) in
                        // check if a card was removed, run animation
                        if old.count > new.count {
                            let diff = old.filter { !new.contains($0) }
                            var temp = diff
                            
                            for i in 0..<diff.count {
                                DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(i)), execute: {
                                    withAnimation {
                                        cardsInHand.removeAll(where: {
                                            $0 == temp.first
                                        })
                                        cards.append(temp.removeFirst())
                                    }
                                })
                            }
                        } else { // card was added
                            let diff = new.filter { !old.contains($0) }
                            var temp = diff
                            
                            for i in 0..<diff.count {
                                DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(i)), execute: {
                                    withAnimation {
                                        cards.removeAll(where: {
                                            $0 == temp.first
                                        })
                                        cardsInHand.append(temp.removeFirst())
                                    }
                                })
                            }
                        }
                    })
            }
            .offset(y: -145)
        }
            
            
//        if (firebaseHelper.gameState?.turn ?? 3 == 3 && firebaseHelper.gameState?.player_turn ?? playerTurn == player.player_num) {
//            VStack {
//                DisplayPlayersHandContainer(player: player, scoringPlays: firebaseHelper.checkPlayerHandForPoints(player.cards_in_hand, firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card), visibilityFor: 3.0)
//                Text(player.name)
//                    .font(.title3)
//                    .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
//            }
//            .onAppear {
//                scoringPlays = firebaseHelper.checkPlayerHandForPoints(player.cards_in_hand, firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card)
//            }
//            .rotationEffect(.degrees(180))
//            .scaleEffect(x: 0.75, y: 0.75)
//            .offset(y: -145)
//            .frame(width: 200, height: 125)
//        } else {
//            VStack(spacing: -45) {
//                Text(player.name)
//                    .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
//                if (firebaseHelper.gameState?.turn ?? 3 == 2) {
//                    TurnTwoView(cardsDragged: .constant(player.cards_dragged), cardsInHand: .constant([]), otherPlayer: true)
//                        .rotationEffect(.degrees(180))
//                        .scaleEffect(x: 0.5, y: 0.5)
//                        .frame(width: 50, height: 125)
//                } else {
//                    CardInHandArea(cardsDragged: .constant([]), cardsInHand: Binding(get: { player.cards_in_hand }, set: { _ in }), showBackside: true)
//                        .rotationEffect(.degrees(180))
//                        .scaleEffect(x: 0.5, y: 0.5)
//                        .frame(width: 50, height: 125)
//                }
//            }
//            .offset(y: -145)
//        }
    }
}

#Preview {
    PlayerView(cards: .constant(Array(0...51)), player: .constant(PlayerState.player_one), index: 0, playerTurn: 0)
        .environmentObject(FirebaseHelper())
}
