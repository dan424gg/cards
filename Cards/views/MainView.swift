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
    @State var showGameView: Bool = false

    var body: some View {
        ZStack {
            if (firebaseHelper.gameState?.is_playing ?? false) && showGameView {
//                NavigationStack {
                    GameView()
//                        .ignoresSafeArea()
//                        .toolbar {
//                            ToolbarItem(placement: .topBarLeading, content: {
//                                Button {
//                                    withAnimation {
//                                        showGameView = false
//                                        firebaseHelper.reinitialize()
//                                    }
//                                } label: {
//                                     Text("Exit")
//                                        .foregroundStyle(.red)
//                                        .font(.custom("LuckiestGuy-Regular", size: 16))
//                                        .baselineOffset(-1.6)
//                                }
//                            })
//                        }
//                }
            } else {
                IntroView()
                    .onAppear {
                        showGameView = true
                    }
            }
        }
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
    }
    .ignoresSafeArea()
}

