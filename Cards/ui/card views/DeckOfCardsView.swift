//
//  DeckOfCardsView.swift
//  Cards
//
//  Created by Daniel Wells on 11/15/23.
//

import SwiftUI

struct DeckOfCardsView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper

    var game = GameState(group_id: 1000, is_playing: false, is_won: false, num_teams: 2, turn: 1, game_name: "cribbage")
    var tempTeam = TeamState(team_num: 1, crib: Array(0...3), has_crib: true, points: 50)
        
    var body: some View {
        HStack(spacing: 50) {
            switch(game.game_name) {
            case "cribbage":
                let teamWithCrib = firebaseHelper.teams.first(where: { team in
                    team.has_crib
                })
                
                if firebaseHelper.gameState?.turn ?? game.turn > 1 {
                    HStack(spacing: -40) {
                        ForEach(Array(teamWithCrib?.crib.enumerated() ?? tempTeam.crib.enumerated()), id: \.offset) { (index, cardId) in
                            CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: false)
                                .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                                .disabled(true)
                        }
                    }
                }
                
                ZStack {
                    if firebaseHelper.gameState == nil {
                        ForEach(Array(game.cards.enumerated()), id: \.offset) { (index, cardId) in
                            if (index == 0) && (game.turn > 1) {
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: false)
                                    .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                    .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                            } else {
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: false)
                                    .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                    .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                            }
                        }
                    } else {
                        ForEach(Array(firebaseHelper.gameState!.cards.enumerated()), id: \.offset) { (index, cardId) in
                            if (index == 0) && (firebaseHelper.gameState!.turn > 1) {
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: false)
                                    .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                    .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                            } else {
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: false)
                                    .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                    .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                            }
                        }
                    }
                }
            default: EmptyView()
            }
        }
    }
}

#Preview {
    DeckOfCardsView()
        .environmentObject(FirebaseHelper())
}
