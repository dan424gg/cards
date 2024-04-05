//
//  PlayerView.swift
//  Cards
//
//  Created by Daniel Wells on 1/27/24.
//

import SwiftUI

struct PlayerView: View {
    @Namespace var names
    @EnvironmentObject var specs: DeviceSpecs
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject var gameObservable: GameObservable
    @Binding var player: PlayerState
    var index: Int
    var playerTurn: Int
    
    @State var shown: Bool = false
    
    var body: some View {
        switch (firebaseHelper.gameState?.game_name ?? "cribbage") {
            case "cribbage":
                ZStack {
                    Text(player.name)
                        .font(.custom("LuckiestGuy-Regular", size: 16))
                        .offset(y: 1.6)
                        .foregroundStyle(((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num && firebaseHelper.gameState?.turn == 2) ? Color("greenForPlayerPlaying") : .black)
                        .zIndex(1.0)
                        .offset(x: shown ? ((player.name.width(usingFont: UIFont.init(name: "LuckiestGuy-Regular", size: 16)!)) / -2.0) - 5.0 : 0.0)

                    if shown {
                        PointContainer(player: player)
                            .geometryGroup()
                            .offset(x: shown ? (35.0 / 2.0) + 5.0 : 0.0)
                            .zIndex(0.0)
                    }
                }
                .onChange(of: firebaseHelper.gameState?.turn, { (_, new) in
                    if new == 0 {
                        withAnimation {
                            shown = false
                        }
                    }
                })
                .onChange(of: firebaseHelper.gameState?.player_turn, {
                    if (((firebaseHelper.gameState?.turn ?? gameObservable.game.turn) >= 3) && ((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num)) {
                        withAnimation {
                            shown = true
                        }
                    }
                })
                .transition(.offset().combined(with: .opacity))
                .frame(height: 56)
            default:
                Text("Shouldn't get here")
        }
    }
}

#Preview {
    return GeometryReader { geo in
        PlayerView(gameObservable: GameObservable(game: .game), player: .constant(PlayerState.player_one), index: 0, playerTurn: 0)
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
