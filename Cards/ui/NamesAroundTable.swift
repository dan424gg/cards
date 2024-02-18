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
    
    @State var playerTurn = 0
    @State var scoringPlays: [ScoringHand] = []
    
    var body: some View {
        ZStack {
            if (firebaseHelper.gameState?.turn ?? gameObservable.game.turn == 4) {
                DisplayPlayersHandContainer(crib: firebaseHelper.gameState?.crib ?? gameObservable.game.crib, visibilityFor: 3.0, scoringPlays: scoringPlays)
                    .rotationEffect(.degrees(Double(180)))
                    .scaleEffect(x: 0.75, y: 0.75)
                    .offset(y: -300)
                    .frame(width: 200, height: 125)
                    .rotationEffect(applyRotation(index: 0))
            } else {
                ForEach(Array(sortedPlayerList.enumerated()), id: \.offset) { (index, player) in
                    PlayerView(player: player, index: index, playerTurn: playerTurn)
                        .rotationEffect(applyRotation(index: index))
                        .rotationEffect(.degrees(Double(tableRotation)))
                        .offset(y: applyOffset(index: index))
                }
            }
            
            Button("stuff") {
                withAnimation {
                    if gameObservable.game.turn == 4 {
                        gameObservable.game.turn = 3
                    } else {
                        gameObservable.game.turn = 4
                    }
//                    playerTurn = (playerTurn + 1) % 7
                }
            }
        }
        .onChange(of: firebaseHelper.gameState?.player_turn ?? playerTurn, {
            if let gameState = firebaseHelper.gameState {
                if gameState.turn > 2 {
                    print("got here with player_turn: \(gameState.player_turn) and tableRotation: \(tableRotation)")
                    withAnimation(.snappy(duration: 1.5)) {
                        tableRotation = (tableRotation - multiplier)
                    }
                }
            } else {
                withAnimation {
                    tableRotation = (tableRotation - multiplier)
                    gameObservable.game.player_turn = (gameObservable.game.player_turn + 1) % 7
                }
            }
        })
        .onChange(of: firebaseHelper.players, initial: true, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil else {
                sortedPlayerList = [PlayerState.player_one, PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six]
                    .sorted(by: { $0.player_num < $1.player_num })
//                    .filter { $0.player_num != 0 }
                return
            }
            
            let playerList = firebaseHelper.players
                .sorted(by: { $0.player_num < $1.player_num })
            
            if firebaseHelper.gameState!.turn > 2 {
                sortedPlayerList = playerList
            } else {
                let beforePlayer = playerList[0..<firebaseHelper.playerState!.player_num]
                let afterPlayer = playerList[firebaseHelper.playerState!.player_num..<playerList.count]
                
                sortedPlayerList = Array(afterPlayer + beforePlayer)
                    .filter { $0.player_num != firebaseHelper.playerState!.player_num }
            }
        })
        .onChange(of: firebaseHelper.gameState?.turn, initial: true, {
            if (firebaseHelper.gameState?.turn == 1) {
                tableRotation = 0
            }
            updateMultiplierAndRotation()
        })
    }
    
    func updateMultiplierAndRotation() {
        if let gameState = firebaseHelper.gameState {
            switch gameState.num_teams {
                case 2:
                    if gameState.num_players == 2 {
                        startingRotation = gameState.turn > 2 ? 180 : 0
                        multiplier = gameState.turn > 2 ? 180 : 0
                    } else {
                        startingRotation = gameState.turn > 2 ? 180 : 270
                        multiplier = 90
                    }
                case 3:
                    if gameState.num_players == 3 {
                        startingRotation = gameState.turn > 2 ? 180 : 300
                        multiplier = 120
                    } else {
                        startingRotation = gameState.turn > 2 ? 180 : 240
                        multiplier = 60
                    }
                default:
                    startingRotation = 0
                    multiplier = 0
            }
        } else {
            startingRotation = 180
            multiplier = 60
        }
    }
    
    func applyOffset(index: Int) -> Double {
//        guard firebaseHelper.gameState != nil else {
//            return 0.0
//        }
        
        return withAnimation {
            if (firebaseHelper.gameState?.turn ?? gameObservable.game.turn > 2) && (firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn == index) {
                return 150.0
            } else {
                return 0.0
            }
        }
    }
    
    func applyRotation(index: Int) -> Angle {
//        if let gameState = firebaseHelper.gameState {
//            if gameState.turn > 2 {
//                return .degrees(Double(startingRotation + (multiplier * index) + tableRotation))
//            } else {
                return .degrees(Double(startingRotation + (multiplier * index)))
//            }
//        } else {
//            return .zero
//        }
    }
}

#Preview {
    NamesAroundTable()
        .environmentObject(FirebaseHelper())
}
