//
//  DeckOfCardsView.swift
//  Cards
//
//  Created by Daniel Wells on 11/15/23.
//

import SwiftUI

struct DeckOfCardsView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject private var gameObservable = GameObservable(game: GameState.game)

    var tempTeam = TeamState(team_num: 1, points: 50)
        
    var body: some View {
        VStack {
            HStack(spacing: 50) {
                switch(gameObservable.game.game_name) {
                    case "cribbage":
                        // displaying the crib
                        if firebaseHelper.gameState?.turn ?? gameObservable.game.turn > 1 {
                            HStack(spacing: -33) {
                                if firebaseHelper.gameState?.turn ?? gameObservable.game.turn == 4 {
                                    ForEach(Array(firebaseHelper.gameState?.crib.enumerated() ?? gameObservable.game.crib.enumerated()), id: \.offset) { (index, cardId) in
                                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: false, naturalOffset: true)
                                    }
                                } else {
                                    ForEach(Array(firebaseHelper.gameState?.crib.enumerated() ?? gameObservable.game.crib.enumerated()), id: \.offset) { (index, cardId) in
                                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: true, naturalOffset: true)
                                    }
                                }
                            }
                        }
                        
                        // displaying the deck
                        ZStack {
                            if firebaseHelper.gameState == nil {
                                ForEach(Array(gameObservable.game.cards.enumerated()), id: \.offset) { (index, cardId) in
                                    CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: true, naturalOffset: true)
                                }
                                
                                if gameObservable.game.turn > 1 {
                                    CardView(cardItem: CardItem(id: gameObservable.game.starter_card), cardIsDisabled: .constant(true), backside: false, naturalOffset: true)
                                }
                            } else {
                                ForEach(Array(firebaseHelper.gameState!.cards.enumerated()), id: \.offset) { (index, cardId) in
                                    CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: true, naturalOffset: true)
                                }
                                
                                if firebaseHelper.gameState!.turn > 1 {
                                    CardView(cardItem: CardItem(id: firebaseHelper.gameState!.starter_card), cardIsDisabled: .constant(true), backside: false, naturalOffset: true)
                                }
                            }
                        }
                    default: EmptyView()
                }
            }
            
//             used for preview testing
//            Button("increment") {
//                gameObservable.game.turn = (gameObservable.game.turn % 4) + 1
//            }
        }
    }
}

#Preview {
    DeckOfCardsView()
        .environmentObject(FirebaseHelper())
}
