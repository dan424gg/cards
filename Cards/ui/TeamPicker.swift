//
//  TeamPicker.swift
//  Cards
//
//  Created by Daniel Wells on 10/22/23.
//

import SwiftUI

struct TeamPicker: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var teamNum = 1
    
    var body: some View {
        VStack {
            Picker("Team", selection: $teamNum) {
                if (firebaseHelper.gameInfo?.num_teams ?? 2) == 3 {
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
        .onAppear(perform: {
            teamNum = firebaseHelper.playerInfo?.team_num ?? 1
        })
        .onChange(of: teamNum) {
            Task {
                await firebaseHelper.changeTeam(newTeamNum: teamNum)
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
