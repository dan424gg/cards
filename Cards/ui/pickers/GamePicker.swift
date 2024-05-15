//
//  GamePicker.swift
//  Cards
//
//  Created by Daniel Wells on 2/27/24.
//

import SwiftUI

struct GamePicker: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State var gameSelected: Games = .cribbage
    @State var preventCyclicalUpdate: Bool = false
    
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
            .disabled(!(firebaseHelper.playerState?.is_lead ?? false))
        } label: {
            HStack(spacing: 2) {
                CText(gameSelected.id.capitalized)
                    .foregroundStyle(specs.theme.colorWay.primary)
            }
        }
        .onChange(of: firebaseHelper.gameState?.game_name, {
            guard firebaseHelper.gameState != nil else {
                return
            }
            if let gameExists = Games.allCases.first(where: { $0.id == firebaseHelper.gameState!.game_name }) {
                gameSelected = gameExists
                preventCyclicalUpdate = true
            }
        })
        .onChange(of: gameSelected, initial: true, {
//            guard firebaseHelper.playerState!.is_lead else {
//                return
//            }
            
            if !preventCyclicalUpdate {
                Task {
                    await firebaseHelper.updateGame(["game_name": gameSelected.id])
                }
            } else {
                preventCyclicalUpdate = false
            }
        })
    }
}

#Preview {
    return GamePicker()
            .environmentObject(FirebaseHelper())
}
