//
//  TeamColorPicker.swift
//  Cards
//
//  Created by Daniel Wells on 1/14/24.
//

import SwiftUI

struct TeamColorPicker: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var teamColor: String = "White"
    @State var listOfColorsAvailable: [String] = []
        
    var body: some View {
        Menu {
            ForEach(listOfColorsAvailable, id: \.self) { colorString in
                Button(colorString) {
                    let oldColor = teamColor
                    
                    Task {
                        await firebaseHelper.updateTeam(newState: ["color": colorString])
                        await firebaseHelper.updateGame(newState: ["colors_available": [colorString]], action: .remove)
                        await firebaseHelper.updateGame(newState: ["colors_available": [oldColor]], action: .append)
                    }
                    
                    teamColor = colorString
                }
            }
        } label: {
            Rectangle()
                .fill(teamColor == "" ? .white : Color(teamColor))
                .aspectRatio(1.0, contentMode: .fill)
        }
        .frame(width: 15, height: 15)
        .onAppear(perform: {
            guard firebaseHelper.teamState != nil else {
                return
            }
            guard firebaseHelper.gameState != nil else {
                return
            }
            
            teamColor = firebaseHelper.teamState?.color == "White" ? firebaseHelper.gameState!.colors_available.randomElement()! : firebaseHelper.teamState!.color
            Task {
                await firebaseHelper.updateTeam(newState: ["color": teamColor])
                await firebaseHelper.updateGame(newState: ["colors_available": [teamColor]], action: .remove)
            }
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