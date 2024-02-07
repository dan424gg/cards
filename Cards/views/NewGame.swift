//
//  NewGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/15/23.
//

import SwiftUI

struct NewGame: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State private var fullName: String = ""
    @FocusState private var focusedField: FocusField?
    
    var gameName: String = "test"
    
    var body: some View {
        VStack {
            Text("Please enter your name (or anything)!")
                .font(.title3)
            TextField(
                "Full Name",
                text: $fullName
            )
            .multilineTextAlignment(.center)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .border(.blue)
            .padding([.leading, .trailing], 48)
            
            NavigationStack {
                NavigationLink {
                    LoadingScreen()
                        .task {
                            await firebaseHelper.startGameCollection(fullName: fullName, gameName: gameName)
                        }
                } label: {
                    Text("Submit")
                }
                .disabled(fullName == "")
            }
        }
    }
}

struct NewGame_Previews: PreviewProvider {
    static var previews: some View {
        NewGame()
            .environmentObject(FirebaseHelper())
    }
}
