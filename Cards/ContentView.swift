//
//  ContentView.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @State var universalClicked = "A game"
    
    var body: some View {
        ZStack {
            if firebaseHelper.gameState?.is_playing ?? false {
                GameView()
                    .onAppear {
                        sheetCoordinator.currentSheet = nil
                    }
                    .transition(.opacity.animation(.easeInOut(duration: 1.0).delay(1.0)))
            } else {
                IntroView(sheetCoordinator: sheetCoordinator)
                    .transition(.opacity.animation(.easeInOut(duration: 1.0)))
            }
        }
        .background {
            Color("OffWhite")
                .opacity(0.07)
            ForEach(Array(0...20), id: \.self) { i in
                LineOfSuits(index: i)
                    .offset(y: CGFloat(-90 * i))
            }
            .position(x: specs.maxX / 2, y: specs.maxY * 1.5)
        }
        .sheetDisplayer(coordinator: sheetCoordinator)
    }
}

#Preview {
    return GeometryReader { geo in
        ContentView()
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
