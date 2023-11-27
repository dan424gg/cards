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
    @State var groupId = 0
    @State var teamNum = 1
    var fullName: String
    var gameName: String
    
    var body: some View {
        VStack {
            VStack {
                Text("Hi \(fullName)!")
                    .task {
                        self.firebaseHelper.initFirebaseHelper()
                    }
                Text("We're gonna start a game of \(gameName)!")
                Text("Others can join with code: \(String(groupId))")
                    .task {
                        if groupId == 0 {
                            await firebaseHelper.startGameCollection(fullName: fullName, gameName: gameName)
                            groupId = firebaseHelper.getGroupId()
                        } else {
                            await firebaseHelper.joinGameCollection(fullName: fullName, id: groupId, gameName: gameName)
                        }
                    }
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
                .disabled(groupId == 0 || !equalNumOfPlayersOnTeam(players: firebaseHelper.players))
        }
    }
}

func equalNumOfPlayersOnTeam(players: [PlayerInformation]) -> Bool {
    if players.count < 2 {
        return false
    }
    
    var teamDict = [String : Int]()
    
    for player in players {
        teamDict.updateValue(((teamDict["\(player.team_num)"] ?? 0) + 1), forKey: "\(player.team_num)")
    }

    let numPlayers = teamDict.popFirst()?.value
    for num in teamDict.values {
        if num != numPlayers! {
            return false
        }
    }
    
    return true
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen(groupId: 0, fullName: "Daniel Wells", gameName: "Cribbage")
            .environmentObject(FirebaseHelper())
    }
}
