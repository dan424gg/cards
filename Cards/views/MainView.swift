//
//  MainView.swift
//  Cards
//
//  Created by Daniel Wells on 3/8/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()

    var body: some View {
        ZStack {
            if (firebaseHelper.gameState?.is_playing ?? false) && specs.inGame {
                    GameView()
                        .geometryGroup()
                        .ignoresSafeArea()
//                        .background(specs.theme.colorWay.background)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                CustomButton(name: "Quit", submitFunction: {
                                    withAnimation {
                                        specs.inGame = false
                                    }
                                }, size: 15, invertColors: true)
                            }
                            
                            ToolbarItem(placement: .topBarTrailing) {
                                CText(firebaseHelper.gameState!.game_name.capitalized, size: 17)
                            }
                        }
//                }
            } else {
                IntroView()
                    .geometryGroup()
            }
        }
        .onChange(of: firebaseHelper.gameState?.is_playing, initial: true, { (_, new) in
            guard new != nil else {
                specs.inGame = true
                return
            }
            
            if new! {
                specs.inGame = true
            }
        })
        .transition(.move(edge: .bottom))
    }
}

#Preview {
    return GeometryReader { geo in
        MainView()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background {
                DeviceSpecs().theme.colorWay.background
            }
    }
    .ignoresSafeArea()
}

