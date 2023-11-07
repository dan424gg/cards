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
    @State var groupId = "Loading..."
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
                Text("Others can join with code: \(groupId)")
                    .task {
                        if groupId == "Loading..." {
                            await firebaseHelper.startGameCollection(fullName: fullName)
                            groupId = "\(firebaseHelper.getGroupId())"
                        } else {
                            await firebaseHelper.joinGameCollection(fullName: fullName, id: Int(groupId)!, teamNum: teamNum)
                        }
                    }
                HStack {
                    Text("Your team:")
                    TeamPicker(teamNum: $teamNum)
                }
            }
            
            VStack {
                Text("Players:")
                HStack {
                    VStack{
                        Text("Team 1:")
                        ForEach(firebaseHelper.players, id:\.self) { player in
                            if player.team_num == 1 {
                                Text(player.name)
                            }
                        }
                    }
                    VStack{
                        Text("Team 2:")
                        ForEach(firebaseHelper.players, id:\.self) { player in
                            if player.team_num == 2 {
                                Text(player.name)
                            }
                        }
                    }
                }
            }
            
            VStack {
                GameStartButton()
                    .disabled(groupId == "Loading...")
            }
        }
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen(groupId: "52112", fullName: "Daniel Wells", gameName: "Cribbage")
            .environmentObject(FirebaseHelper())
    }
}
