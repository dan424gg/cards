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
    @StateObject private var teamOne = TeamObservable(team: TeamState.team_one)
    @StateObject private var teamTwo = TeamObservable(team: TeamState.team_two)
    
    var body: some View {
        VStack {
            VStack {
                Text("Hi \(firebaseHelper.playerState?.name ?? "Player")!")
                    .task {
                        self.firebaseHelper.initFirebaseHelper()
                    }
                Text("We're gonna start a game of \(firebaseHelper.gameState?.game_name ?? "Game")!")
                Text("Others can join with code: \(String(firebaseHelper.gameState?.group_id ?? 0))")
                HStack {
                        Text("Want to change your team?    -->")
                            .bold()
                    TeamPicker()
                }
            }
            
            VStack {
                HStack {
                    // for preview
                    if firebaseHelper.teams == [] {
                        VStack {
                            HStack {
                                TeamColorPicker()
                                VStack {
                                    Text("Team \(TeamState.team_one.team_num)")
                                        .underline(true, color: Color(TeamState.team_one.color))
                                    Text("Dan")
                                    Text("Katie")
                                }
                            }
                        }
                        
                        VStack {
                            Text("Team \(TeamState.team_two.team_num)")
                                .underline(true, color: Color(TeamState.team_two.color))
                            Text("Ben")
                            Text("Alex")
                        }
                    } else {
                        ForEach(firebaseHelper.teams.sorted(by: { $0.team_num < $1.team_num }), id:\.self) { team in
                            VStack {
                                HStack {
                                    Text("Team \(team.team_num)")
                                        .underline(true, color: Color(team.color))
                                    if firebaseHelper.playerState?.team_num ?? 1 == team.team_num {
                                        TeamColorPicker()
                                    }
                                }
                                ForEach(firebaseHelper.players, id:\.self) { player in
                                    if player.team_num == team.team_num {
                                        Text(player.name!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if firebaseHelper.playerState?.is_lead! ?? false {
                GameStartButton()
            } else {
                Text("Waiting to start game...")
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { firebaseHelper.gameState?.is_playing ?? false },
            set: {_ in }
        )) {
            GameView()
        }
    }
}

func equalNumOfPlayersOnTeam(players: [PlayerState]) -> Bool {
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
