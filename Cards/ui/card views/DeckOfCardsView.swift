//
//  DeckOfCardsView.swift
//  Cards
//
//  Created by Daniel Wells on 11/15/23.
//

import SwiftUI

struct DeckOfCardsView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper

    var game = GameInformation(group_id: 1000, is_ready: false, is_won: false, num_teams: 2, turn: 1, game_name: "cribbage")
    var tempTeam = TeamInformation(team_num: 1, crib: [CardItem(id: 0, value: "A", suit: "heart"), CardItem(id: 1, value: "5", suit: "heart"), CardItem(id: 2, value: "4", suit: "spade"), CardItem(id: 3, value: "K", suit: "heart")], has_crib: true, points: 50)
        
    var body: some View {
        HStack(spacing: 50) {
            switch(game.game_name) {
            case "cribbage":
                let teamWithCrib = firebaseHelper.teams.first(where: { team in
                    team.has_crib
                })
                
                if firebaseHelper.gameInfo?.turn ?? game.turn > 1 {
                    HStack(spacing: -40) {
                        ForEach(Array(teamWithCrib?.crib.enumerated() ?? tempTeam.crib.enumerated()), id: \.offset) { (index, card) in
                            CardView(cardItem: card, cardIsDisabled: .constant(true), backside: false)
                                .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                                .disabled(true)
                        }
                    }
                }
                
                ZStack {
                    if firebaseHelper.gameInfo == nil {
                        ForEach(Array(game.cards.enumerated()), id: \.offset) { (index, card) in
                            if (index == 0) && (game.turn > 1) {
                                CardView(cardItem: card, cardIsDisabled: .constant(true), backside: false)
                                    .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                    .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                            } else {
                                CardView(cardItem: card, cardIsDisabled: .constant(true), backside: false)
                                    .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                    .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                            }
                        }
                    } else {
                        ForEach(Array(firebaseHelper.gameInfo!.cards.enumerated()), id: \.offset) { (index, card) in
                            if (index == 0) && (firebaseHelper.gameInfo!.turn > 1) {
                                CardView(cardItem: card, cardIsDisabled: .constant(true), backside: false)
                                    .offset(y: -Double.random(in: -5.0...5.0) / 5.0)
                                    .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                            } else {
                                CardView(cardItem: card, cardIsDisabled: .constant(true), backside: false)
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
