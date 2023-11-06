//
//  StatusDot.swift
//  Cards
//
//  Created by Daniel Wells on 10/31/23.
//

import SwiftUI

struct ShowStatus: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    var players = [PlayerInformation.player_one, PlayerInformation.player_two]

    var body: some View {
        if firebaseHelper.playerInfo == nil {
            ForEach(players, id: \.self) { player in
                HStack {
                    Text(player.name)
                    if player.is_ready {
                        Circle()
                            .fill(.green)
                            .frame(width: 10, height: 10)
                    } else {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                    }
                }
            }
        } else {
            ForEach(firebaseHelper.players, id: \.self) { player in
                HStack {
                    Text(player.name)
                    if player.is_ready {
                        Circle()
                            .fill(.green)
                            .frame(width: 10, height: 10)
                    } else {
                        Circle()
                            .fill(.red)
                            .frame(width: 10, height: 10)
                    }
                }
            }
        }
    }
}

#Preview {
    ShowStatus()
        .environmentObject(FirebaseHelper())
}
