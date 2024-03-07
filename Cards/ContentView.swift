//
//  ContentView.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @State var universalClicked = "A game"
    
    @State var size: CGSize = CGSize(width: 1.0, height: 1.0)
    @State var opacity: Double = 0.5
    @State var timer: Timer?
    
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
//        .overlay {
//            RoundedRectangle(cornerRadius: 20.0)
//                .fill(.white)
//                .opacity(opacity)
//                .shadow(radius: 5)
//                .scaleEffect(size)
//                .onLongPressGesture(minimumDuration: 1.0, perform: {
//                    timer?.invalidate()
//                    timer = nil
//                    withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
//                        size = CGSize(width: 1.0, height: 1.0)
//                        opacity = 0.5
//                    }
//                }, onPressingChanged: { change in
//                    if change {
//                        timer?.invalidate()
//                        timer = nil
//                        withAnimation(.bouncy(duration: 0.3)) {
//                            size = CGSize(width: 0.85, height: 0.85)
//                            opacity = 0.9
//                        }
//                    } else {
//                        withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
//                            size = CGSize(width: 1.0, height: 1.0)
//                        }
//                        
//                        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
//                            withAnimation(.smooth(duration: 0.3)) {
//                                opacity = 0.5
//                            }
//                        })
//                    }
//                })
//                .frame(width: 7, height: 200)
//                .position(x: specs.maxX - 20.0, y: specs.maxY / 2)
//        }
        .background {
            ZStack {
                Color("OffWhite")
                    .opacity(0.07)
                ForEach(Array(0...20), id: \.self) { i in
                    LineOfSuits(index: i)
                        .offset(y: CGFloat(-90 * i))
                        .zIndex(0.0)
                }
                .position(x: specs.maxX / 2, y: specs.maxY * 1.5)
            }
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
