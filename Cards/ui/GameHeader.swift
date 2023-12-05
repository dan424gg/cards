//
//  GameHeader.swift
//  Cards
//
//  Created by Daniel Wells on 12/4/23.
//

import SwiftUI

struct GameHeader: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text("Exit")
                        .padding()
                    Spacer()
                }
                
                HStack {
                    Text(firebaseHelper.gameInfo?.game_name.capitalized ?? "Game")
                        .font(.title2)
                }
            }
//            .padding()
            Spacer()
        }
    }
}

#Preview {
    GameHeader()
        .environmentObject(FirebaseHelper())
}
