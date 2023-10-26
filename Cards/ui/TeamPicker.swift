//
//  TeamPicker.swift
//  Cards
//
//  Created by Daniel Wells on 10/22/23.
//

import SwiftUI

struct TeamPicker: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var teamNum: Int
    
    var body: some View {
        VStack {
            Picker("Team", selection: $teamNum) {
                ForEach(1...2, id:\.self) { num in
                    Text("\(num)")
                }
            }
        }
        .onChange(of: teamNum) { _ in
            print(teamNum)
            Task {
                await firebaseHelper.changeTeam(newTeamNum: teamNum)
            }
        }
    }
}

struct TeamPicker_Previews: PreviewProvider {
    static var previews: some View {
        TeamPicker(teamNum: .constant(1))
            .environmentObject(FirebaseHelper())
    }
}
