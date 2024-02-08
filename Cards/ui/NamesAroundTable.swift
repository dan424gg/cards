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
    @State var tableRotation = 0
    
    var body: some View {
        ZStack {
            ForEach(Array(sortedPlayerList.enumerated()), id: \.offset) { (index, player) in
                PlayerView(player: player, index: index)
                    .if(firebaseHelper.gameState?.turn ?? gameObservable.game.turn == 3, transform: {
                        // gives rotation needed during turn 3 for cribbage
                        $0.rotationEffect(firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn == player.player_num ? .degrees(180.0) : .degrees(0.0))
                    })
                    .offset(y: -140)
                    .rotationEffect(applyRotation(index: index))
            }
            Button("rotate") {
                withAnimation(.snappy(duration: 1.5, extraBounce: 0.15)) {
                    tableRotation += 180
                    gameObservable.game.player_turn = (gameObservable.game.player_turn + 1) % sortedPlayerList.count
                }
            }
        }
        .onChange(of: firebaseHelper.players, initial: true, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil else {
                sortedPlayerList = [PlayerState.player_one, PlayerState.player_two]
                    .sorted(by: { $0.player_num < $1.player_num })
                return
            }
            
            let playerList = firebaseHelper.players
                .lazy
                .sorted(by: { $0.player_num < $1.player_num })
            
            let beforePlayer = playerList[0..<firebaseHelper.playerState!.player_num]
            let afterPlayer = playerList[firebaseHelper.playerState!.player_num..<playerList.count]
            
            // rotate players list
            sortedPlayerList = Array(afterPlayer + beforePlayer)
                .if(firebaseHelper.gameState!.turn < 3,
                    then: { array in
                        array = array.filter { $0.player_num != firebaseHelper.playerState!.player_num }
                    },
                    else: { array in
                        // Do something else if the condition is false
                    })
        })
        .onAppear(perform: {
            updateMultiplierAndRotation()
        })
    }
    
    func updateMultiplierAndRotation() {
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
    
    func applyRotation(index: Int) -> Angle {
        if (firebaseHelper.gameState?.turn ?? gameObservable.game.turn == 3) {
            return .degrees(Double(180 + (180 * index)) + Double(tableRotation))
        } else {
            return .degrees(Double(startingRotation + (multiplier * index)))
        }
    }
}

#Preview {
    NamesAroundTable()
        .environmentObject(FirebaseHelper())
}
