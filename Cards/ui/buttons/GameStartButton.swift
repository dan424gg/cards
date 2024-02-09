//
//  GameStartButton.swift
//  Cards
//
//  Created by Daniel Wells on 10/22/23.
//

import SwiftUI

struct GameStartButton: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    
    var body: some View {
        VStack {
            Button("Play!") {
                Task {
                    await firebaseHelper.updatePlayerNums()
                    await firebaseHelper.updateGame(["is_playing": true, "turn": 1])
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .disabled((firebaseHelper.gameState?.group_id ?? 0) == 0 || !equalNumOfPlayersOnTeam(players: firebaseHelper.players))
        }
    }
}

struct GameStartButton_Previews: PreviewProvider {
    static var previews: some View {
        GameStartButton()
            .environmentObject(FirebaseHelper())
    }
}
