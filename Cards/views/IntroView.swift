//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

enum IntroViewType {
    case newGame, existingGame, loadingScreen, settings, nothing
}

struct IntroView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State var introView: IntroViewType = .nothing
    @State var showNewGameView: Bool = false
    @State var showExistingGameView: Bool = false
    @State var showLoadingView: Bool = false
    @State var scale: Double = 1.0
            
    var body: some View {
        ZStack {
            if introView == .newGame {
                NewGameView(introView: $introView)
                    .geometryGroup()
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endTextEditing()
                        withAnimation(.snappy.speed(1.0)) {
                            introView = .nothing
                        }
                    }
            } else if introView == .existingGame {
                ExistingGameView(introView: $introView)
                    .geometryGroup()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endTextEditing()
                        withAnimation(.snappy.speed(1.0)) {
                            introView = .nothing
                        }
                    }
            } else if introView == .loadingScreen {
                LoadingScreen()
                    .geometryGroup()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        endTextEditing()
//                        withAnimation(.snappy.speed(1.0)) {
//                            introView = .nothing
//                        }
//                    }
            } else if introView == .settings {
                SettingsView(introView: $introView)
                    .geometryGroup()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endTextEditing()
                        withAnimation(.snappy.speed(1.0)) {
                            introView = .nothing
                        }
                    }
            } else {
                ZStack {
                    Text("CARDS")
                        .font(.custom("LuckiestGuy-Regular", size: determineFont("CARDS", Int(specs.maxX), 110)))
                        .tracking(8)
                        .foregroundStyle(specs.theme.colorWay.title)
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.3)
                        .offset(x: 5)

                    VStack(spacing: 15) {
                        MainScreenButton(buttonType: .existingGame, submitFunction: {
                            withAnimation(.snappy.speed(1.0)) {
                                introView = .existingGame
                            }
                        })
                        
                        MainScreenButton(buttonType: .newGame, submitFunction: {
                            withAnimation(.snappy.speed(1.0)) {
                                introView = .newGame
                            }
                        })
                    }
                    .position(x: specs.maxX / 2, y: specs.maxY * 0.75)
                    
                    ImageButton(image: Image(systemName: "gearshape.circle.fill"), submitFunction: {
                        withAnimation(.snappy.speed(1.0)){
                            introView = .settings
                        }
                    })
                    .foregroundStyle(specs.theme.colorWay.primary, specs.theme.colorWay.secondary)
                    .font(.system(size: 50, weight: .regular))
                    .position(x: specs.maxX * 0.9, y: specs.maxY * 0.1)
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    return GeometryReader { geo in
        IntroView()
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
