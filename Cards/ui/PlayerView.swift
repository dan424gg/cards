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
    
    let player: PlayerState
    let index: Int
    
    @State var startingRotation = 0
    @State var multiplier = 0
    
    var body: some View {
        VStack(spacing: -35) {
            Text(player.name)
                .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
            if (firebaseHelper.gameState?.turn ?? 2 == 2) {
                TurnTwoView(cardsDragged: .constant(player.cards_dragged), cardsInHand: .constant([]), otherPlayer: true)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(x: 0.5, y: 0.5)
                    .frame(width: 50, height: 125)
            } else {
                CardInHandArea(cardsDragged: .constant([]), cardsInHand: Binding(get: { player.cards_in_hand }, set: { _ in }), showBackside: true)
                    .rotationEffect(.degrees(180))
                    .scaleEffect(x: 0.5, y: 0.5)
                    .frame(width: 50, height: 125)
            }
        }
        .onChange(of: [startingRotation, multiplier], initial: true, {
            print("index \(index) starting rotation: \(startingRotation) multiplier: \(multiplier)")
        })
        .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
//        .onAppear {
//            updateRotationAndMultiplier()
//        }
    }
    
    private func updateRotationAndMultiplier() {
        switch(firebaseHelper.gameState?.num_teams ?? 2) {
            case 2:
                if firebaseHelper.gameState?.num_players ?? 2 == 2 {
                    startingRotation = 0
                    multiplier = 0
                } else {
                    startingRotation = 270
                    multiplier = 90
                }
            case 3:
                if firebaseHelper.gameState?.num_players ?? 3 == 3 {
                    startingRotation = 315
                    multiplier = 90
                } else {
                    startingRotation = 240
                    multiplier = 60
                }
            default:
                startingRotation = 0
                multiplier = 0
        }
    }
}

#Preview {
    PlayerView(player: PlayerState(), index: 0)
        .environmentObject(FirebaseHelper())
}
