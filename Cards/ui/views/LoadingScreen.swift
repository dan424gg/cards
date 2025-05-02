//
//  NewGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/5/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct LoadingScreen: View {
    @Environment(DeviceSpecs.self) private var specs
    @Environment(GameHelper.self) private var gameHelper
    @Binding var introView: IntroViewType
    @FocusState private var isFocused: Bool
    @StateObject private var teamOne = TeamObservable(team: TeamState.team_one)
    @StateObject private var teamTwo = TeamObservable(team: TeamState.team_two)
    @State var size: CGSize = .zero
    @State var name: String = ""
    @State var isEditing: Bool = false
    
    @State var keyboardBufferOffset: Double = 48.0
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                CText("Pre-Game", size: 40)
                HStack {
                    CText(String(gameHelper.gameState?.group_id ?? 12345))
                        .foregroundStyle(specs.theme.colorWay.primary)
                        .padding(10)
                        .background(
                            Color.white
                        )
                        .clipShape(Capsule())
                    
                    GamePicker()
                        .padding(10)
                        .background(
                            Color.white
                        )
                        .clipShape(Capsule())
                }
                
                PlayerEditor
                    .frame(width: specs.maxX * 0.6, height: 24)
                    .padding(10)
                    .background(
                        Color.white
                    )
                    .clipShape(Capsule())
            
                playersList()
                    .getSize(onChange: { size in
                        keyboardBufferOffset += size.width
                    })
                
                Group {
                    if gameHelper.playerState?.is_lead ?? true {
                        CustomButton(name: "Play", submitFunction: {
                            Task {
                                await gameHelper.reorderPlayerNumbers()
                                await gameHelper.updateGame(["is_playing": true])
                            }
                            
                            gameHelper.logAnalytics(.game_started)
                            gameHelper.logAnalytics(.game_being_played, ["game": gameHelper.gameState!.game_name])
                            gameHelper.logAnalytics(.num_players, ["players": gameHelper.gameState!.num_players])
                            gameHelper.logAnalytics(.num_teams, ["teams": gameHelper.gameState!.num_teams])
                            for team in gameHelper.teams {
                                gameHelper.logAnalytics(.color_picked, ["color_picked": team.color])
                            }
                        })
                        .disabled(!gameHelper.equalNumOfPlayersOnTeam())
                    } else {
                        CText("Waiting to start...")
                            .foregroundStyle(specs.theme.colorWay.white)
                    }
                }
                .frame(minHeight: 48)
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(specs.theme.colorWay.primary)
                    .shadow(radius: 10)
            }
        }
        .overlay(alignment: .topTrailing) {
            ImageButton(image: Image(systemName: "x.circle.fill"), submitFunction: {
                withAnimation(.snappy.speed(1.0)) {
                    introView = .nothing
                    endTextEditing()
                }
            })
            .offset(x: 20.0, y: -20.0)
            .font(.system(size: 45, weight: .heavy))
            .foregroundStyle(specs.theme.colorWay.primary, specs.theme.colorWay.secondary)
        }
        .KeyboardAwarePadding(offset: -keyboardBufferOffset)
        .frame(width: specs.maxX * 0.8)
        .onTapGesture {
            endTextEditing()
        }
    }
    
    var PlayerEditor: some View {
        HStack {
            TextField("", text: $name, prompt: Text("Name").foregroundStyle(.gray.opacity(0.5)))
                .foregroundStyle(specs.theme.colorWay.primary)
                .font(.custom("LuckiestGuy-Regular", size: 24))
                .baselineOffset(-5)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .onChange(of: gameHelper.playerState?.name, initial: true, { (old, new) in
                    guard old != nil, new != nil else {
                        name = "No Name"
                        return
                    }
                    
                    name = new!
                    
                    if new! != old! {
                        gameHelper.logAnalytics(.name_length, ["name_length": new!.count])
                    }
                })
                .onChange(of: isFocused, { (old, new) in
                    if old && !new {
                        Task {
                            await gameHelper.updatePlayer(["name": name])
                        }
                    }
                })
            Divider()
            TeamPicker()
                .frame(width: 35)
            Divider()
            TeamColorPicker()
                .frame(width: 35)
        }
    }
    
    struct playersList: View {
        @Environment(DeviceSpecs.self) private var specs
        @Environment(GameHelper.self) private var gameHelper
        
        var teams: [TeamState] {
            if gameHelper.gameState != nil {
                return gameHelper.teams
            } else {
                return GameState.teams
            }
        }
        
        var players: [PlayerState] {
            if gameHelper.gameState != nil {
                return gameHelper.players
            } else {
                return GameState.players
            }
        }
        
        var user: PlayerState {
            if gameHelper.playerState != nil {
                return gameHelper.playerState!
            } else {
                return PlayerState.player_one
            }
        }
        
        var body: some View {
            HStack(spacing: 20) {
                VStack {
                    HStack (spacing: 20) {
                        ForEach(teams.sorted(by: { $0.team_num < $1.team_num }), id:\.self) { team in
                            CText("Team \(team.team_num)", size: 19)
                                .foregroundStyle(Color(team.color))
                                .frame(width: 75)
                        }
                    }
                    
                    HStack (spacing: 20) {
                        ForEach(teams.sorted(by: { $0.team_num < $1.team_num }), id:\.self) { team in
                            VStack {
                                if user.team_num == team.team_num {
                                    CText(user.name, size: Int(determineFont(user.name, 75, 18)))
                                        .foregroundStyle(specs.theme.colorWay.white)
                                }
                                
                                ForEach(players.filter { $0.team_num == team.team_num }, id: \.self) { player in
                                    CText(player.name, size: Int(determineFont(user.name, 75, 18)))
                                        .foregroundStyle(specs.theme.colorWay.white)
                                }
                            }
                            .frame(width: 75, alignment: .top)
                        }
                    }
                    .frame(alignment: .top)
                }
            }
            
        }
    }
}

func determineFont(_ string: String, _ containerSize: Int, _ defaultFontSize: Int = 18) -> CGFloat {
    var newFontSize: Int = defaultFontSize
    while string.width(usingFont: UIFont.init(name: "LuckiestGuy-Regular", size: CGFloat(newFontSize))!) > CGFloat(containerSize) {
        newFontSize -= 1
    }
    
    return CGFloat(newFontSize)
}

#Preview {
    return GeometryReader { geo in
        LoadingScreen(introView: .constant(.loadingScreen))
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(Color("OffWhite").opacity(0.1))

    }
    .ignoresSafeArea()
}
