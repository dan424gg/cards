//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

enum IntroViewType {
    case newGame, existingGame, loadingScreen, nothing
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
                        withAnimation(.snappy(duration: 0.3)) {
                            introView = .nothing
                        }
                    }
            } else if introView == .existingGame {
                ExistingGameView(introView: $introView)
                    .geometryGroup()
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endTextEditing()
                        withAnimation(.snappy(duration: 0.3)) {
                            introView = .nothing
                        }
                    }
            } else if introView == .loadingScreen {
                LoadingScreen()
                    .geometryGroup()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endTextEditing()
                        withAnimation(.snappy(duration: 0.3)) {
                            introView = .nothing
                        }
                    }
            } else {
                ZStack {
                    Text("CARDS")
                        .font(.custom("LuckiestGuy-Regular", size: 120))
                        .tracking(8)
                        .foregroundStyle(Color.theme.white)
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.3)
                        .offset(x: 5)

                    VStack(spacing: 15) {
                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                introView = .existingGame
                            }
                        } label: {
                            Text("Join Game")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .font(.custom("LuckiestGuy-Regular", size: 24))
                                .baselineOffset(-5)
                                .foregroundStyle(Color.theme.primary)
                                .frame(width: specs.maxX * 0.75)
                        }
                        .background(Color.theme.white)
                        .clipShape(Capsule())
                        
                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                introView = .newGame
                            }
                        } label: {
                            Text("New Game")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .font(.custom("LuckiestGuy-Regular", size: 24))
                                .baselineOffset(-5)
                                .foregroundStyle(Color.theme.white)
                                .frame(width: specs.maxX * 0.75)
                        }
                        .background(Color.theme.primary)
                        .clipShape(Capsule())
                    }
                    .position(x: specs.maxX / 2, y: specs.maxY * 0.75)
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
    }
    .ignoresSafeArea()
}
