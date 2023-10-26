//
//  NewGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/15/23.
//

import SwiftUI

struct NewGame: View {
    var name: String = "test"
    @State private var fullName: String = ""
    
    var body: some View {
        VStack {
            TextField(
                "Full Name",
                text: $fullName
            )
                .multilineTextAlignment(.center)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .border(.blue)
                .padding([.leading, .trailing], 48)
            
            NavigationLink {
                LoadingScreen(fullName: fullName, gameName: name)
            } label: {
                Text("Submit")
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
