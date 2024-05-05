//
//  NewGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/5/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject var specs: DeviceSpecs
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @FocusState private var isFocused: Bool
    @StateObject private var teamOne = TeamObservable(team: TeamState.team_one)
    @StateObject private var teamTwo = TeamObservable(team: TeamState.team_two)
    @State var size: CGSize = .zero
    @State var name: String = ""
    @State var isEditing: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    Text(String(firebaseHelper.gameState?.group_id ?? 12345))
                        .foregroundStyle(specs.theme.colorWay.primary)
                        .font(.custom("LuckiestGuy-Regular", size: 18))
                        .baselineOffset(-1.8)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                        )
                    
                    GamePicker()
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                        )
                }
                
                PlayerEditor
                .frame(width: specs.maxX * 0.6, height: 22)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .frame(width: specs.maxX * 0.66, height: 40)
                )
            
                playersList()
                
                if firebaseHelper.playerState?.is_lead ?? true {
                    CustomButton(name: "Play", submitFunction: {
                        Task {
                            await firebaseHelper.reorderPlayerNumbers()
                            await firebaseHelper.updateGame(["is_playing": true])
                        }
                        
                        firebaseHelper.logAnalytics(AnalyticsEvents.game_started)
                        firebaseHelper.logAnalytics(AnalyticsEvents.num_players, ["players": 5])
                        firebaseHelper.logAnalytics(AnalyticsEvents.num_teams, ["teams": firebaseHelper.gameState!.num_teams])
                    })
                    .disabled(!firebaseHelper.equalNumOfPlayersOnTeam())

                } else {
                    Text("Waiting to start game...")
                        .foregroundStyle(specs.theme.colorWay.white)
                        .font(.custom("LuckiestGuy-Regular", size: 18))
                        .baselineOffset(-1.8)
                }
            }
            .padding(25)
            .background {
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(specs.theme.colorWay.primary)
            }
        }
        .onTapGesture {
            endTextEditing()
        }
    }
    
    var PlayerEditor: some View {
        HStack {
            TextField("", text: $name, prompt: Text("Name").foregroundStyle(.gray.opacity(0.5)))
                .foregroundStyle(specs.theme.colorWay.primary)
                .font(.custom("LuckiestGuy-Regular", size: 18))
                .baselineOffset(-1.8)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .onChange(of: firebaseHelper.playerState?.name, initial: true, {
                    name = firebaseHelper.playerState?.name ?? "No Name"
                })
                .onChange(of: isFocused, { (old, new) in
                    if old && !new {
                        Task {
                            await firebaseHelper.updatePlayer(["name": name])
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
        @EnvironmentObject var specs: DeviceSpecs
        @EnvironmentObject var firebaseHelper: FirebaseHelper
        
        var teams: [TeamState] {
            if firebaseHelper.gameState != nil {
                return firebaseHelper.teams
            } else {
                return GameState.teams
            }
        }
        
        var players: [PlayerState] {
            if firebaseHelper.gameState != nil {
                return firebaseHelper.players
            } else {
                return GameState.players
            }
        }
        
        var user: PlayerState {
            if firebaseHelper.playerState != nil {
                return firebaseHelper.playerState!
            } else {
                return PlayerState.player_one
            }
        }
        
        var body: some View {
            HStack(spacing: 20) {
                VStack {
                    HStack (spacing: 20) {
                        ForEach(teams.sorted(by: { $0.team_num < $1.team_num }), id:\.self) { team in
                            Text("Team \(team.team_num)")
                                .font(.custom("LuckiestGuy-Regular", size: 20))
                                .baselineOffset(-2)
                                .shadow(color: .black, radius: team.color == "Red" ? 5 : 1)
                                .padding(6)
                                .foregroundStyle(Color(team.color))
                                .background {
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color(team.color), lineWidth: 1.3)
                                        .offset(y: -25)
                                        .clipped()
                                        .offset(y: 22)
                                        .shadow(color: .black, radius: team.color == "Red" ? 5 : 1)
                                }
                        }
                    }
                    
                    HStack (spacing: 20) {
                        ForEach(teams.sorted(by: { $0.team_num < $1.team_num }), id:\.self) { team in
                            VStack {
                                if user.team_num == team.team_num {
                                    Text(user.name)
                                        .foregroundStyle(specs.theme.colorWay.white)
                                        .font(.custom("LuckiestGuy-Regular", size: determineFont(user.name, 75)))
                                        .baselineOffset(-1.8)
                                }
                                
                                ForEach(players.filter { $0.team_num == team.team_num }, id: \.self) { player in
                                    Text(player.name)
                                        .foregroundStyle(specs.theme.colorWay.white)
                                        .font(.custom("LuckiestGuy-Regular", size: determineFont(player.name, 75)))
                                        .baselineOffset(-1.8)
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
        LoadingScreen()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(Color("OffWhite").opacity(0.1))

    }
    .ignoresSafeArea()
}
