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
        if (firebaseHelper.gameState?.turn ?? 3 == 3 && firebaseHelper.gameState?.player_turn ?? 0 == player.player_num) {
            VStack {
                Text(player.name)
                    .font(.title3)
                    .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                HStack {
                    ForEach(player.cards_in_hand, id: \.self) { card in
                        CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(false))
                    }
                }
            }
            .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
            .scaleEffect(x: 0.75, y: 0.75)
            .frame(width: 200, height: 125)
        } else {
            VStack(spacing: -35) {
                Text(player.name)
                    .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                if (firebaseHelper.gameState?.turn ?? 3 == 2) {
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
            .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
        }
    }
}

#Preview {
    PlayerView(player: PlayerState.player_one, index: 0)
        .environmentObject(FirebaseHelper())
}
