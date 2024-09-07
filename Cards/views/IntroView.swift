//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

enum IntroViewType {
    case newGame, existingGame, loadingScreen, settings, nothing, singlePlayer, multiPlayer
}

struct IntroView: View {
    @Environment(GameHelper.self) private var gameHelper
    @Environment(DeviceSpecs.self) private var specs
    @State var introView: IntroViewType = .nothing
    @State var showNewGameView: Bool = false
    @State var showExistingGameView: Bool = false
    @State var showLoadingView: Bool = false
    @State var scale: Double = 1.0
            
    var body: some View {
        ZStack {
            switch introView {
                case .newGame:
                    NewGameView(introView: $introView)
                        .geometryGroup()
                        .KeyboardAwarePadding(offset: -48)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            endTextEditing()
                        }
                case .existingGame:
                    ExistingGameView(introView: $introView)
                        .geometryGroup()
                        .KeyboardAwarePadding(offset: -48)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            endTextEditing()
                        }
                case .loadingScreen:
                    LoadingScreen(introView: $introView)
                        .geometryGroup()
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            endTextEditing()
                        }
                case .settings:
                    SettingsView(introView: $introView)
                        .geometryGroup()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            endTextEditing()
                        }
                case .nothing, .multiPlayer:
                    ZStack {
                        CText("CARDS PLAYGROUND", size: Int(determineFont("PLAYGROUND", Int(specs.maxX - 40), 115)))
                            .foregroundStyle(specs.theme.colorWay.title)
                            .multilineTextAlignment(.center)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.25)

                        VStack(spacing: 15) {
                            if introView == .multiPlayer {
                                MultiplayerSubView(introView: $introView)
                            }
                            
                            MainScreenButton(buttonType: .multiPlayer, submitFunction: {
                                withAnimation(.snappy.speed(1.0)) {
                                    if introView == .multiPlayer {
                                        introView = .nothing
                                    } else {
                                        gameHelper.database = Firebase()
                                        introView = .multiPlayer
                                    }
                                }
                            })
                            
                            MainScreenButton(buttonType: .singlePlayer, submitFunction: {
                                withAnimation(.snappy.speed(1.0)) {
                                    introView = .singlePlayer
                                    
                                    gameHelper.database = Local()
                                    Task {
                                        await gameHelper.startGameCollection(fullName: "")
                                    }
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
                case .singlePlayer:
                    SinglePlayerView(introView: $introView)
                        .geometryGroup()
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            endTextEditing()
                        }
            }
        }
    }
    
    struct MultiplayerSubView: View {
        @Environment(GameHelper.self) var gameHelper
        @Environment(DeviceSpecs.self) var specs
        @Binding var introView: IntroViewType
        
        var body: some View {
            HStack(spacing: -10) {
                TextButton(text: "new game", submitFunction: {
                    withAnimation(.snappy.speed(1.0)){
                        introView = .newGame
                    }
                })
                
                TextButton(text: "join game", submitFunction: {
                    withAnimation(.snappy.speed(1.0)){
                        introView = .existingGame
                    }
                })
//                Group {
//                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
//                        .overlay {
//                            CText("New Game", size: 35)
//                                .multilineTextAlignment(.center)
//                        }
//                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
//                        .overlay {
//                            CText("Join Game", size: 35)
//                                .multilineTextAlignment(.center)
//                        }
//                }
//                .clipShape(RoundedRectangle(cornerRadius: 25.0))
//                .scaleEffect(0.8)
            }
            .frame(width: specs.maxX * 0.75, height: 125)
            .background {
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(specs.theme.colorWay.primary)
            }
        }
    }
}

#Preview {
    return GeometryReader { geo in
        IntroView()
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background {
                DeviceSpecs().theme.colorWay.background
            }
    }
    .ignoresSafeArea()
}
