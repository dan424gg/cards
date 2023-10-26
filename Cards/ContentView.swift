//
//  ContentView.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI

struct ContentView: View {
    @State var universalClicked = "A game"
    var body: some View {
        NavigationView {
            VStack {
                Text("What game do you want to play??")
                GameButton(universalClicked: $universalClicked, name: "Cribbage")
                GameButton(universalClicked: $universalClicked, name: "Uno")
                GameButton(universalClicked: $universalClicked, name: "Rummy")
            }
            .buttonStyle(.bordered)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FirebaseHelper())
    }
}
