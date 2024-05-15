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
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    @Binding var player: PlayerState
    var index: Int
    var playerTurn: Int
    @State var fontSize: Int = 16
//    var defaultColor: Color = specs.theme.colorWay.textColor
    @State var shown: Bool = false
    
    var body: some View {
//        ZStack {
            switch (firebaseHelper.gameState?.game_name ?? "cribbage") {
                case "cribbage":
                    VStack {
                        ZStack {
                            if (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer) == player.player_num {
                                CribMarker(scale: 0.45)
                                    .offset(x: (player.name.width(usingFont: UIFont.init(name: "LuckiestGuy-Regular", size: Double(fontSize))!) / 2) + 13)
                            }
                            
                            CText(player.name, size: Int(fontSize))
                                .zIndex(1.0)

                            if shown {
                                PointContainer(player: player)
                                    .geometryGroup()
                                    .offset(x: -(player.name.width(usingFont: UIFont.init(name: "LuckiestGuy-Regular", size: Double(fontSize))!) / 2) - 22)
                                    .zIndex(0.0)
                                    .getSize { size in
                                        print("pointcontainer size: \(size)")
                                        print("pointcontainer offset: \(-(player.name.width(usingFont: UIFont.init(name: "LuckiestGuy-Regular", size: Double(fontSize))!) / 2) - 22)")
                                    }
                            }
                        }
                        .frame(width: 130)
                        .onAppear {
                            if fontSize == 16 {
                                fontSize = Int(determineFont(player.name, 45, fontSize))
                            }
                        }
                    }
                    .onChange(of: firebaseHelper.gameState?.turn, { (_, new) in
                        if new == 5 {
                            withAnimation {
                                shown = false
                            }
                        }
                    })
                    .onChange(of: firebaseHelper.gameState?.player_turn, {
                        if (((firebaseHelper.gameState?.turn ?? gameObservable.game.turn) == 3) && ((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == player.player_num)) {
                            withAnimation {
                                shown = true
                            }
                        }
                    })
                    .transition(.offset().combined(with: .opacity))
                default:
                    CText("Shouldn't get here")
            }
//        }
    }
}

#Preview {
    return GeometryReader { geo in
        PlayerView(player: .constant(PlayerState.player_one), index: 0, playerTurn: 0)
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
