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
                case .nothing:
                    ZStack {
                        CText("CARDS PLAYGROUND", size: Int(determineFont("PLAYGROUND", Int(specs.maxX - 40), 115)))
                            .foregroundStyle(specs.theme.colorWay.title)
                            .multilineTextAlignment(.center)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.25)

                        VStack(spacing: 15) {
                            MainScreenButton(buttonType: .multiPlayer, submitFunction: {
                                withAnimation(.snappy.speed(1.0)) {
                                    introView = .multiPlayer
                                }
                            })
                            
                            MainScreenButton(buttonType: .singlePlayer, submitFunction: {
                                withAnimation(.snappy.speed(1.0)) {
                                    introView = .singlePlayer
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
                    EmptyView()
                case .multiPlayer:
                    EmptyView()
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
