//
//  GameOutcomeView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

struct GameOutcomeView: View {
    @Environment(GameHelper.self) private var gameHelper
    @Environment(DeviceSpecs.self) private var specs
    @State var endGameOpacity: Double = 1.0
    @State var scale: Double = 1.0
    var outcome: GameOutcome

    var body: some View {
        Group {
            switch (outcome) {
                case .win:
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .prominent))
                            .ignoresSafeArea(.all)
                        VStack(spacing: 50) {
                            CText("You won!", size: 50)
                                .foregroundStyle(.green)
                                .shadow(color: .white, radius: 10)
                        }
                    }
                    .zIndex(0)
                    .transition(.opacity)
                case .lose:
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .prominent))
                            .ignoresSafeArea(.all)
                        VStack(spacing: 50) {
                            CText("You lost!", size: 50)
                                .foregroundStyle(.red)
                                .shadow(color: .white, radius: 10)
                        }
                    }
                    .zIndex(0)
                    .transition(.opacity)
                case .undetermined:
                    EmptyView()
            }
        }
        .onAppear {
            Task {
                await gameHelper.updateGame(["completed": true])
            }
            
            gameHelper.logAnalytics(.game_ended)
        }
        .animation(.easeInOut.speed(0.5).delay(1.0), value: outcome)
    }
}

#Preview {
    return GeometryReader { geo in
        ZStack {
            GameView()
            GameOutcomeView(outcome: .lose)
        }
        .environment({ () -> DeviceSpecs in
            let envObj = DeviceSpecs()
            envObj.setProperties(geo)
            return envObj
        }() )
        .environment(GameHelper())
        .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
        .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
