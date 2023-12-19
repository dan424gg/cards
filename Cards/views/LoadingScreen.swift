//
//  NewGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/5/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    
    var body: some View {
        VStack {
            VStack {
                Text("Hi \(firebaseHelper.playerInfo?.name ?? "Player")!")
                    .task {
                        self.firebaseHelper.initFirebaseHelper()
                    }
                Text("We're gonna start a game of \(firebaseHelper.gameInfo?.game_name ?? "Game")!")
                Text("Others can join with code: \(String(firebaseHelper.gameInfo?.group_id ?? 0))")
                HStack {
                        Text("Want to change your team?    -->")
                            .bold()
                    TeamPicker()
                }
            }
            
            VStack {
                HStack {
                    ForEach(firebaseHelper.teams, id:\.self) { team in
                        VStack {
                            Text("Team \(team.team_num):")
                            ForEach(firebaseHelper.players, id:\.self) { player in
                                if player.team_num == team.team_num {
                                    Text(player.name!)
                                }
                            }
                        }
                    }
                }
            }
            
            GameStartButton()
                .padding()
                .disabled((firebaseHelper.gameInfo?.group_id ?? 0) == 0 || !equalNumOfPlayersOnTeam(players: firebaseHelper.players))
        }
    }
}

func equalNumOfPlayersOnTeam(players: [PlayerInformation]) -> Bool {
    if players.count < 2 {
        return false
    } else {
        var numOfPlayers = [0,0,0]
        for player in players {
            numOfPlayers[player.team_num! - 1] += 1
        }
        // if third team has no players, or the count is equal to another team
        return numOfPlayers[0] == numOfPlayers[1] && (numOfPlayers[2] == 0 || numOfPlayers[0] == numOfPlayers[2])
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
            .environmentObject(FirebaseHelper())
    }
}
