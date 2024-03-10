//
//  MainView.swift
//  Cards
//
//  Created by Daniel Wells on 3/8/24.
//

import SwiftUI

struct MainView: View {
    @Binding var visible: Bool
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()

    var body: some View {
        ZStack {
            if firebaseHelper.gameState?.is_playing ?? false {
                GameView()
                    .onAppear {
                        sheetCoordinator.currentSheet = nil
                    }
                    .transition(.opacity.animation(.easeInOut(duration: 0.5).delay(0.5)))
            } else {
                IntroView(blur: $visible, sheetCoordinator: sheetCoordinator)
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
            }
        }
    }
}

#Preview {
    return GeometryReader { geo in
        MainView(visible: .constant(false))
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

