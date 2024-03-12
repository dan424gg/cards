//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

extension AnyTransition {
    static var moveAndMoveQuicker: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).animation(.snappy(duration: 0.01, extraBounce: 0.3)),
            removal: .move(edge: .bottom).animation(.snappy(duration: 0.01, extraBounce: 0.3))
        )
    }
}

struct IntroView: View {
    @Binding var blur: Bool
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State var showNewGameView: Bool = false
    @State var showExistingGameView: Bool = false
    @State var scale: Double = 1.0
    @StateObject var sheetCoordinator: SheetCoordinator<SheetType>
            
    var body: some View {
        ZStack {
            if showNewGameView {
                NewGameView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
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
                        .font(.system(size: 100, weight: .light))
                        .foregroundStyle(.black)
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.25)
                    
                    VStack(spacing: 15) {
                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                showExistingGameView = true
                            }
                        } label: {
                            Text("Join Game")
                                .foregroundStyle(.black)
                                .font(.system(size: 15, weight: .thin))
                                .frame(width: specs.maxX * 0.66, height: 33)
                        }
                        .background(.thinMaterial)
                        .tint(Color("OffWhite").opacity(0.7))
                        .buttonStyle(.bordered)
                        
                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                showNewGameView = true
                            }
                        } label: {
                            Text("New Game")
                                .foregroundStyle(.black)
                                .font(.system(size: 15, weight: .thin))
                                .frame(width: specs.maxX * 0.66, height: 33)
                        }
                        .background(.thinMaterial)
                        .tint(Color("OffWhite").opacity(0.7))
                        .buttonStyle(.bordered)
                    }
                    .position(x: specs.maxX / 2, y: specs.maxY * 0.75)
                }
                .transition(.opacity)
            }
        }

    }
}

#Preview {
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()

    return GeometryReader { geo in
        IntroView(blur: .constant(false), sheetCoordinator: sheetCoordinator)
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
