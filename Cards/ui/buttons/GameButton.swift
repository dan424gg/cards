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
    var name: String

    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                if universalClicked == name {
                    universalClicked = "A game"
                } else {
                    universalClicked = name
                }
            }) {
                Text(name)
            }
            .buttonStyle(.bordered)
            
            if universalClicked == name {
                HStack {
                    NavigationLink {
                        NewGame(name: name)
                    } label: {
                        Text("Start a new game")
                    }
                    
                    NavigationLink {
                        ExistingGame(name: name)
                    } label: {
                        Text("Join an existing game")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct GameButton_Previews: PreviewProvider {
    static var previews: some View {
        GameButton(universalClicked: .constant("A game"), name: "Cribbage")
            .environmentObject(FirebaseHelper())
    }
}
