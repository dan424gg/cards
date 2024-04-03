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
    @Environment(\.namespace) var namespace
    @EnvironmentObject var specs: DeviceSpecs
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    @State var sortedPlayerList: [PlayerState] = []
    @State var startingRotation = 0
    @State var multiplier = 0
    @State var tableRotation = 0
    @State var playerTurn = 0
    
    private var timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(Array($sortedPlayerList.enumerated()), id: \.offset) { (index, player) in
                PlayerView(gameObservable: gameObservable, player: player, index: index, playerTurn: playerTurn)
                    .offset(y: -185)
                    .rotationEffect(applyRotation(index: index))
                    .rotationEffect(.degrees(Double(tableRotation)))
                    .offset(y: applyOffset(index: index))
            }
        }
        .onReceive(timer, perform: { _ in
            gameObservable.game.player_turn = ((gameObservable.game.player_turn + 1) % gameObservable.game.num_players)
        })
        .onAppear {
            updateMultiplierAndRotation()
        }
        .onChange(of: firebaseHelper.players, initial: true, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil else {
                sortedPlayerList = [PlayerState.player_one, PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six]
                    .sorted(by: { $0.player_num < $1.player_num })
                    .filter { $0.player_num != 0 }
                return
            }
            
            sortedPlayerList = firebaseHelper.players
//                .sorted(by: { $0.player_num < $1.player_num })
//            
//            if firebaseHelper.gameState!.turn > 2 {
//                sortedPlayerList = playerList
//            } else {
//                let beforePlayer = playerList[0..<firebaseHelper.playerState!.player_num]
//                let afterPlayer = playerList[firebaseHelper.playerState!.player_num..<playerList.count]
//                
//                sortedPlayerList = Array(afterPlayer + beforePlayer)
//                    .filter { $0.player_num != firebaseHelper.playerState!.player_num }
//            }
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
            startingRotation = 240
            multiplier = 60
        }
    }
    
    func applyOffset(index: Int) -> Double {
//        guard firebaseHelper.gameState != nil else {
//            return 0.0
//        }
        
        return withAnimation {
//            if (firebaseHelper.gameState?.turn ?? gameObservable.game.turn > 2) && (firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn == index) {
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
    return GeometryReader { geo in
        NamesAroundTable()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(Color("OffWhite").opacity(0.1))
        
    }
    .ignoresSafeArea()
}
