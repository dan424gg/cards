//
//  GamePicker.swift
//  Cards
//
//  Created by Daniel Wells on 2/27/24.
//

import SwiftUI

struct GamePicker: View {
    @Environment(GameHelper.self) var gameHelper
    @Environment(DeviceSpecs.self) var specs
    @State var gameSelected: Games = .cribbage
    @State var preventCyclicalUpdate: Bool = false
    var color: Color?
    
    enum Games: String, CaseIterable, Identifiable {
        case cribbage, goFish, rummy
        
        var id: String { rawValue }
        
        var name: String {
            if self == .goFish {
                "go fish"
            } else {
                rawValue
            }
        }
    }
    
    var body: some View {
        Menu {
            Picker("Game", selection: $gameSelected) {
                ForEach(Games.allCases, id: \.self) { game in
                    CText(game.name.capitalized)
                }
            }
            .disabled(!(gameHelper.playerState?.is_lead ?? false))
        } label: {
            HStack(spacing: 2) {
                CText(gameSelected.id.capitalized)
                    .foregroundStyle(color ?? specs.theme.colorWay.primary)
                    .underline()
            }
        }
        .onChange(of: gameHelper.gameState?.game_name, {
            guard gameHelper.gameState != nil else {
                return
            }
            if let gameExists = Games.allCases.first(where: { $0.id == gameHelper.gameState!.game_name }) {
                gameSelected = gameExists
                preventCyclicalUpdate = true
            }
        })
        .onChange(of: gameSelected, initial: true, {
            if !preventCyclicalUpdate {
                Task {
                    await gameHelper.updateGame(["game_name": gameSelected.id])
                }
            } else {
                preventCyclicalUpdate = false
            }
        })
    }
}

#Preview {
    return GeometryReader { geo in
        GamePicker()
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
