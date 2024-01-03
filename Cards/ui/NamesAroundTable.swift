//
//  NamesAroundTable.swift
//  Cards
//
//  Created by Daniel Wells on 11/13/23.
//
//
//  When previewing view, make sure to set the default value on line 41
//  and the corresponding default value for number of players

import SwiftUI

struct NamesAroundTable: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var sortedPlayerList: [PlayerState]?
    @State var startingRotation = 0
    @State var multiplier = 0
    
    var body: some View {
        ZStack {
            ForEach(Array(sortedPlayerList?.enumerated()
                      ?? [PlayerState.player_one, PlayerState.player_two, PlayerState.player_three, PlayerState.player_four]
                            .filter { $0.player_num != 1 }
                            .sorted(by: { $0.player_num! < $1.player_num!})
                            .enumerated()
                     ), id: \.offset) {
                (index, player) in
                VStack(spacing: 0) {
                    Text(player.name!)
                    CardInHandArea(cardsDragged: .constant([]), cardsInHand: Binding(get: { player.cards_in_hand! }, set: { _ in }), showBackside: true)
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: 0.5, y: 0.5)
                        .offset(y: -25)
                }
                .offset(y: -120)
                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                .onChange(of: firebaseHelper.players, initial: false, {
                    sortedPlayerList = firebaseHelper.players
                        .lazy
                        .filter { $0.player_num != firebaseHelper.playerState!.player_num}
                        .sorted(by: { $0.player_num! < $1.player_num!})
                })
            }
            .onAppear(perform: {
                switch(firebaseHelper.gameState?.num_teams ?? 2) {
                case 2:
                    if firebaseHelper.gameState?.num_players == 2 {
                        startingRotation = 0
                        multiplier = 0
                    } else {
                        startingRotation = 270
                        multiplier = 90
                    }
                case 3:
                    if firebaseHelper.gameState?.num_players == 3 {
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
            })
        }
    }
}

#Preview {
    NamesAroundTable()
        .environmentObject(FirebaseHelper())
}
