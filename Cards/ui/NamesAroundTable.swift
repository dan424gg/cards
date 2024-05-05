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
    @StateObject var gameObservable: GameObservable
    @State var sortedPlayerList: [PlayerState] = []
    @State var startingRotation = 0
    @State var multiplier = 0
    @State var tableRotation = 0
    @State var playerTurn = 0
    
    @State var doStuff = false
    var timer = Timer.publish(every: 2.0, on: .main, in: .common)
    
    var body: some View {
        ZStack {
            ForEach(Array($sortedPlayerList.enumerated()), id: \.offset) { (index, player) in
                PlayerView(player: player, index: index, playerTurn: playerTurn)
                    .offset(y: -185)
                    .rotationEffect(applyRotation(index: index))
            }
        }
        .onAppear {
            updateMultiplierAndRotation(firebaseHelper.gameState ?? gameObservable.game)
        }
        .onChange(of: firebaseHelper.players, initial: true, { (_, new) in
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil else {
                sortedPlayerList = GameState.players
                return
            }
            
            if new.count > 2 {
                let beforePlayer = new[0..<firebaseHelper.playerState!.player_num]
                let afterPlayer = new[(firebaseHelper.playerState!.player_num + 1)..<new.count]
                
                sortedPlayerList = Array(afterPlayer + beforePlayer)
            } else {
                sortedPlayerList = new
            }
        })
    }
    
    func updateMultiplierAndRotation(_ gameState: GameState) {
        switch gameState.num_teams {
            case 2:
                if gameState.num_players == 2 {
                    startingRotation = 0
                    multiplier = 0
                } else {
                    startingRotation = 270
                    multiplier = 90
                }
            case 3:
                if gameState.num_players == 3 {
                    startingRotation = 300
                    multiplier = 120
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
        return .degrees(Double(startingRotation + (multiplier * index)))
    }
}

#Preview {
    return GeometryReader { geo in
        NamesAroundTable(gameObservable: GameObservable(game: .game))
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
