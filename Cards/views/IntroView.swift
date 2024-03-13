//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI


struct IntroView: View {
    @Binding var blur: Bool
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State var showNewGameView: Bool = false
    @State var showExistingGameView: Bool = false
    @State var scale: Double = 1.0
            
    var body: some View {
        ZStack {
            if showNewGameView {
                NewGameView()
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endTextEditing()
                        if showNewGameView {
                            withAnimation(.snappy(duration: 0.3)) {
                                showNewGameView = false
                            }
                        } else if showExistingGameView {
                            withAnimation(.snappy(duration: 0.3)) {
                                showExistingGameView = false
                            }
                        }
                    }
            } else if showExistingGameView {
                ExistingGameView()
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        endTextEditing()
                        if showNewGameView {
                            withAnimation(.snappy(duration: 0.3)) {
                                showNewGameView = false
                            }
                        } else if showExistingGameView {
                            withAnimation(.snappy(duration: 0.3)) {
                                showExistingGameView = false
                            }
                        }
                    }
            } else {
                ZStack {
                    Text("CARDS")
                        .font(.custom("LuckiestGuy-Regular", size: 120))
                        .tracking(10)
                        .foregroundStyle(Color.theme.title)
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.3)
                        .offset(x: 5)
                        .shadow(radius: 5)
                        .shadow(radius: 5)

                    VStack(spacing: 15) {
                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                showExistingGameView = true
                            }
                        } label: {
                            Text("Join Game")
                                .padding()
                                .foregroundStyle(Color.theme.primary)
                                .font(.custom("LuckiestGuy-Regular", size: 20))
                                .offset(y: 2)
                                .frame(width: specs.maxX * 0.75)
                        }
                        .background(Color.theme.white)
                        .clipShape(Capsule())
                        .shadow(color: Color.theme.secondary, radius: 2)

                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                showNewGameView = true
                            }
                        } label: {
                            Text("New Game")
                                .padding()
                                .foregroundStyle(Color.theme.white)
                                .font(.custom("LuckiestGuy-Regular", size: 20))
                                .offset(y: 2)
                                .frame(width: specs.maxX * 0.75)
                        }
                        .background(Color.theme.primary)
                        .clipShape(Capsule())
                        .shadow(color: Color.theme.secondary, radius: 2)
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
        IntroView(blur: .constant(false))
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
