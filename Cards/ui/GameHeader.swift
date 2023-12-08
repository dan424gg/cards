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
                    VStack {
                        Text(firebaseHelper.gameInfo?.game_name.capitalized ?? "Game")
                            .font(.title2)
                        Text("\(firebaseHelper.gameInfo?.group_id ?? 0)")
                    }
                }
            }
            Spacer()
        }
    }
}

#Preview {
    GameHeader()
        .environmentObject(FirebaseHelper())
}
