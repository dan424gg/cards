//
//  Header.swift
//  Cards
//
//  Created by Daniel Wells on 11/6/23.
//

import SwiftUI

struct Header: View {
    var teams =  [TeamInformation.team_one, TeamInformation.team_two]
    var players = [PlayerInformation.player_one, PlayerInformation.player_two]
    var game = GameInformation(group_id: 1000, is_ready: false, is_won: false, num_players: 2, turn: 1)
    
    @EnvironmentObject var firebaseHelper: FirebaseHelper

    var body: some View {
//        GeometryReader { geo in
            VStack(alignment: .center, spacing: 20) {
                Text("Cribbage")
                    .font(.title)
                Divider()
                HStack(spacing: 20) {
                    if firebaseHelper.teams == [] {
                        ForEach(teams, id: \.self) { team in
                            VStack {
                                Text("Team \(team.team_num)")
                                    .font(.headline)
                                Text("\(team.points)")
                                    .font(.subheadline)
                            }
                            
                            if team != teams.last {
                                Divider()
                            }
                        }
                    } else {
                        ForEach(firebaseHelper.teams, id: \.self) { team in
                            VStack {
                                Text("Team \(team.team_num)")
                                    .font(.headline)
                                Text("\(team.points)")
                                    .font(.subheadline)
                            }
                            
                            if team != firebaseHelper.teams.last {
                                Divider()
                            }
                        }
                    }
                }
                .frame(height: 10)
                Divider()
                HStack(spacing: 30) {
                    ShowStatus()
                }
//            }
//            .frame(height: geo.frame(in: .global).height / 4)
        }
            .padding()
    }
}

#Preview {
    Header()
        .environmentObject(FirebaseHelper())
}
