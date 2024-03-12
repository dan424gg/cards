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
    @StateObject var sheetCoordinator: SheetCoordinator<SheetType>
            
    var body: some View {
        ZStack {
            if showNewGameView || showExistingGameView {
                ZStack {
                    Color.blue
                        .opacity(0.000001)
                        .frame(width: specs.maxX, height: specs.maxY)
                        .onTapGesture {
                            if showNewGameView {
                                withAnimation(.spring(duration: 0.3)) {
                                    blur = false
                                    showNewGameView = false
                                }
                            } else if showExistingGameView {
                                withAnimation(.spring(duration: 0.3)) {
                                    blur = false
                                    showExistingGameView = false
                                }
                            }
                        }
                        .zIndex(0.0)

                    RoundedRectangle(cornerRadius: 20.0)
                        .fill(.white)
                        .fill(Color("OffWhite").opacity(0.2))
                        .frame(width: 300, height: 300)
                        .position(x: specs.maxX / 2, y: specs.maxY / 2)
                        .zIndex(1.0)
                    
                    if showNewGameView {
                        NewGameView()
                            .zIndex(1.0)
                    } else if showExistingGameView {
                        ExistingGameView()
                            .zIndex(1.0)
                    }
                }
//                .transition(blurReplace)
            } else {
                ZStack {
                    Text("CARDS")
                        .font(.system(size: 100, weight: .light))
                        .foregroundStyle(.black)
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.25)
                        .zIndex(1.0)
                    
                    VStack(spacing: 15) {
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                showExistingGameView = true
                                blur.toggle()
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
                            withAnimation(.spring(duration: 0.3)) {
                                showNewGameView = true
                                blur.toggle()
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
                    .zIndex(1.0)
                    .position(x: specs.maxX / 2, y: specs.maxY * 0.75)
                }
                .transition(.blurReplace)
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
