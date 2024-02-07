//
//  GameButton.swift
//  Cards
//
//  Created by Daniel Wells on 10/5/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct GameButton: View {
    @Binding var universalClicked: String
    var gameName: String

    var body: some View {
        VStack {
            Button(action: {
                if universalClicked == gameName {
                    universalClicked = "A game"
                } else {
                    universalClicked = gameName
                }
            }) {
                Text(gameName.capitalized)
            }
            .buttonStyle(.bordered)
            
            if universalClicked == gameName {
                HStack {
                    NavigationLink {
                        NewGame(gameName: gameName)
                    } label: {
                        Text("New Game")
                    }
                    
                    NavigationLink {
                        ExistingGame(gameName: gameName)
                    } label: {
                        Text("Join Game")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct GameButton_Previews: PreviewProvider {
    static var previews: some View {
        GameButton(universalClicked: .constant("A game"), gameName: "Cribbage")
            .environmentObject(FirebaseHelper())
    }
}
