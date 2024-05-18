//
//  TeamColorPicker.swift
//  Cards
//
//  Created by Daniel Wells on 1/14/24.
//

import SwiftUI

struct TeamColorPicker: View {
    @Environment(GameHelper.self) private var gameHelper
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
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(teamColor == "" ? .white : Color(teamColor))
                    .font(.system(size: 15, weight: .thin))
                    .frame(width: 25, height: 25)
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
        .environment(GameHelper())
}
