//
//  ContentView.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var universalClicked = "A game"
    var body: some View {
//        SwiftUIView()
        NavigationStack {
            VStack {
                Text("What game do you want to play??")
                GameButton(universalClicked: $universalClicked, gameName: "cribbage")
                GameButton(universalClicked: $universalClicked, gameName: "uno")
                GameButton(universalClicked: $universalClicked, gameName: "rummy")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirebaseHelper())
    }
}
