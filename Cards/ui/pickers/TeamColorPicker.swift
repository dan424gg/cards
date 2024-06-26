//
//  TeamColorPicker.swift
//  Cards
//
//  Created by Daniel Wells on 1/14/24.
//

import SwiftUI

struct TeamColorPicker: View {
    @EnvironmentObject var gameHelper: GameHelper
    @State var teamColor: String = ""
    @State var listOfColorsAvailable: [String] = ["Red", "Blue", "Teal", "Green", "Yellow", "Orange"]
    @State var size: CGSize = .zero
        
    var body: some View {
        Menu {
            ForEach(listOfColorsAvailable, id: \.self) { colorString in
                Button(colorString) {
                    let oldColor = teamColor
                    
                    Task {
                        await gameHelper.updateTeam(["color": colorString])
                        await gameHelper.updateGame(["colors_available": [colorString]], arrayAction: .remove)
                        await gameHelper.updateGame(["colors_available": [oldColor]], arrayAction: .append)
                    }
                    
                    teamColor = colorString
                }
            }
        } label: {
            HStack {
                Rectangle()
                    .fill(teamColor == "" ? .white : Color(teamColor))
                    .font(.system(size: 15, weight: .thin))
                    .frame(width: 20, height: 20)
            }
        }
        .onChange(of: gameHelper.teamState, initial: true, {
            teamColor = gameHelper.teamState?.color ?? "Orange"
        })
        .onChange(of: gameHelper.gameState?.colors_available, initial: true, {
            listOfColorsAvailable = (gameHelper.gameState?.colors_available ?? ["Red", "Blue", "Teal", "Green", "Yellow", "Orange"]).sorted()
        })
    }
}

#Preview {
    TeamColorPicker()
        .environmentObject(GameHelper())
}
