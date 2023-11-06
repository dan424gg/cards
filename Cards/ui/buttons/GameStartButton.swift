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
            if self.firebaseHelper.playerInfo != nil && self.firebaseHelper.playerInfo!.is_lead {
                NavigationLink {
                    Cribbage().navigationBarBackButtonHidden(true)
                } label: {
                    Text("Play!")
                }
                .buttonStyle(.borderedProminent)
                .simultaneousGesture(TapGesture().onEnded {
                    self.firebaseHelper.updateGame(newState: ["is_ready": true])
                })
            } else {
                if self.firebaseHelper.gameInfo != nil && self.firebaseHelper.gameInfo!.is_ready {
                    NavigationLink {
                        Cribbage().navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Play!")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct GameStartButton_Previews: PreviewProvider {
    static var previews: some View {
        GameStartButton()
            .environmentObject(FirebaseHelper())
    }
}
