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
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    @State var sortedPlayerList: [PlayerState] = []
    @State var startingRotation = 0
    @State var multiplier = 0
    
    var body: some View {
        ZStack {
            ForEach(Array(sortedPlayerList.enumerated()), id: \.offset) { (index, player) in
                PlayerView(player: player, index: index)
                    .offset(y: -140)
                    .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
            }
        }
        .onChange(of: firebaseHelper.players, initial: true, {
            sortedPlayerList = firebaseHelper.players == [] ? [PlayerState.player_one, PlayerState.player_two, PlayerState.player_three] : firebaseHelper.players
                .lazy
                .filter { $0.player_num != firebaseHelper.playerState!.player_num}
                .sorted(by: { $0.player_num < $1.player_num })
        })
        .onAppear(perform: {
            updateMultiplierAndRotation()
        })
    }
    
    func updateMultiplierAndRotation() {
        switch(firebaseHelper.gameState?.num_teams ?? 2) {
            case 2:
                if firebaseHelper.gameState?.num_players ?? 4 == 2 {
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
    NamesAroundTable()
        .environmentObject(FirebaseHelper())
}
