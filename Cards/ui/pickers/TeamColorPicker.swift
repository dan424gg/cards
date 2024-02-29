//
//  TeamColorPicker.swift
//  Cards
//
//  Created by Daniel Wells on 1/14/24.
//

import SwiftUI

struct TeamColorPicker: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var teamColor: String = ""
    @State var listOfColorsAvailable: [String] = ["Red", "Blue", "Teal", "Green", "Yellow", "Orange"]
    @State var size: CGSize = .zero
        
    var body: some View {
        Menu {
            ForEach(listOfColorsAvailable, id: \.self) { colorString in
                Button(colorString) {
                    let oldColor = teamColor
                    
                    Task {
                        await firebaseHelper.updateTeam(["color": colorString])
                        await firebaseHelper.updateGame(["colors_available": [colorString]], arrayAction: .remove)
                        await firebaseHelper.updateGame(["colors_available": [oldColor]], arrayAction: .append)
                    }
                    
                    teamColor = colorString
                }
            }
        } label: {
            HStack {
//                Text(teamColor)
//                    .font(.system(size: 12))
                Rectangle()
                    .fill(teamColor == "" ? .white : Color(teamColor))
                    .font(.system(size: 15))
                    .frame(width: 15, height: 15)
            }
        }
        .onChange(of: firebaseHelper.teamState, initial: true, {
            teamColor = firebaseHelper.teamState?.color ?? "Orange"
        })
        .onChange(of: firebaseHelper.gameState?.colors_available, initial: true, {
            listOfColorsAvailable = firebaseHelper.gameState?.colors_available ?? ["Red", "Blue", "Teal", "Green", "Yellow", "Orange"]
        })
    }
}

#Preview {
    TeamColorPicker()
        .environmentObject(FirebaseHelper())
}
