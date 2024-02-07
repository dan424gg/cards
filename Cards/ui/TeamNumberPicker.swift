//
//  TeamPicker.swift
//  Cards
//
//  Created by Daniel Wells on 10/22/23.
//

import SwiftUI

struct TeamPicker: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var teamNum = 0
    
    var body: some View {
        VStack {
            Picker("Team", selection: $teamNum) {
                if (firebaseHelper.gameState?.num_teams ?? 2) == 3 {
                    ForEach(1...3, id:\.self) { num in
                        Text("\(num)")
                    }
                } else {
                    ForEach(1...2, id:\.self) { num in
                        Text("\(num)")
                    }
                }
            }
        }
        .onChange(of: firebaseHelper.playerState?.team_num, initial: true, {
            guard firebaseHelper.playerState != nil else {
                return
            }
            
            if (firebaseHelper.playerState!.team_num != teamNum) {
                print("in here")
                teamNum = firebaseHelper.playerState!.team_num
            }
        })
        .onChange(of: teamNum) {
            if (firebaseHelper.playerState!.team_num != teamNum) {
                print("in here too")
                Task {
                    await firebaseHelper.changeTeam(newTeamNum: teamNum)
                }
            }
        }
    }
}

struct TeamPicker_Previews: PreviewProvider {
    static var previews: some View {
        TeamPicker()
            .environmentObject(FirebaseHelper())
    }
}
