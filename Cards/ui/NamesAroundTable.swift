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
    @State var tableRotation = 180
    
    @State var playerTurn = 0
    
    var body: some View {
        ZStack {
            ForEach(Array(sortedPlayerList.enumerated()), id: \.offset) { (index, player) in
                PlayerView(player: player, index: index, playerTurn: playerTurn)
                    .rotationEffect(applyRotation(index: index))
                    .offset(y: applyOffset(index: index))
            }
//            Button("stuff") {
//                withAnimation(.snappy(duration: 1.5)) {
//                    tableRotation = (tableRotation - multiplier)
//                    playerTurn = (playerTurn + 1) % 6
//                    gameObservable.game.player_turn = (gameObservable.game.player_turn + 1) % 2
//                }
//            }
        }
//        .onChange(of: sortedPlayerList, initial: true, {
//            print("sortedPlayerList")
//            for player in sortedPlayerList {
//                print("\nplayer hand(\(player.name): \(player.cards_in_hand))")
//            }
//        })
//        .onChange(of: firebaseHelper.gameState?.player_turn, {
//            if let gameState = firebaseHelper.gameState {
//                if gameState.turn > 2 {
//                    print("got here with player_turn: \(gameState.player_turn) and tableRotation: \(tableRotation)")
//                    withAnimation(.snappy(duration: 1.5)) {
//                        tableRotation = (tableRotation - multiplier)
//                    }
//                }
//            }
//        })
        .onChange(of: firebaseHelper.players, initial: true, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil else {
                sortedPlayerList = [PlayerState.player_one, PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six]
                    .sorted(by: { $0.player_num < $1.player_num })
//                    .filter { $0.player_num != 0 }
                return
            }
            
            print("\nAFTER PLAYER CHANGE")
            print("\nGAMESTATE\n\(firebaseHelper.gameState!)")
            print("\nPLAYERS\n\(firebaseHelper.players)")
            print("\nTEAMS\n\(firebaseHelper.teams)")
            
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
        guard firebaseHelper.gameState != nil else {
            return 0.0
        }
        
        return withAnimation {
//            if (firebaseHelper.gameState!.turn > 2) && (firebaseHelper.gameState!.player_turn == index) {
//                return 150.0
//            } else {
                return 0.0
//            }
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
