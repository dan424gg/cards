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
    
    var player: PlayerState
    var index: Int
    var playerTurn: Int
    
    @State var startingRotation = 0
    @State var multiplier = 0
    @State var scoringPlays: [ScoringHand] = []
    
    var body: some View {
        if (firebaseHelper.gameState?.turn ?? 3 == 2) {
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
                    CardInHandArea(cardsDragged: .constant([]), cardsInHand: Binding(get: { player.cards_in_hand }, set: { _ in }), showBackside: player.player_num > firebaseHelper.gameState?.player_turn ?? playerTurn)
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: 0.5, y: 0.5)
                        .frame(width: 50, height: 125)
                }
                .offset(y: -145)
            }
        } else {
            VStack(spacing: -45) {
                Text(player.name)
                    .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                CardInHandArea(cardsDragged: .constant([]), cardsInHand: Binding(get: { player.cards_in_hand }, set: { _ in }), showBackside: true)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(x: 0.5, y: 0.5)
                    .frame(width: 50, height: 125)
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
    PlayerView(player: PlayerState.player_one, index: 0, playerTurn: 0)
        .environmentObject(FirebaseHelper())
}
