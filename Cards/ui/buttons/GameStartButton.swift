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
            NavigationLink {
                GameView().navigationBarBackButtonHidden(true)
            } label: {
                Text("Play!")
            }
            .buttonStyle(.borderedProminent)
            .simultaneousGesture(TapGesture().onEnded {
                if self.firebaseHelper.playerInfo != nil && self.firebaseHelper.playerInfo!.is_lead! {
                    Task {
                        await self.firebaseHelper.updateGame(newState: ["is_ready": true])
                    }
                }
            })
        }
    }
}

struct GameStartButton_Previews: PreviewProvider {
    static var previews: some View {
        GameStartButton()
            .environmentObject(FirebaseHelper())
    }
}
