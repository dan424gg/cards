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
            RoundedRectangle(cornerRadius: 20.0)
                .fill(Color.theme.primary)
                .frame(width: 300, height: size.height)
            
            VStack(spacing: 20) {
                HStack {
                    Text(String(firebaseHelper.gameState?.group_id ?? 12345))
                        .foregroundStyle(Color.theme.primary)
                        .font(.custom("LuckiestGuy-Regular", size: 18))
                        .offset(y: 1.8)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                                .stroke(Color.theme.secondary, lineWidth: 1.0)
                        )
                    
                    GamePicker()
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                                .stroke(Color.theme.secondary, lineWidth: 1.0)
                        )
                }
                
                HStack {
                    TextField("", text: $name, prompt: Text("Name").foregroundStyle(.gray.opacity(0.5)))
                        .foregroundStyle(Color.theme.primary)
                        .font(.custom("LuckiestGuy-Regular", size: 18))
                        .offset(y: 1.8)
                        .multilineTextAlignment(.center)
                        .focused($isFocused)
                        .onChange(of: firebaseHelper.playerState?.name, initial: true, {
                            name = firebaseHelper.playerState?.name ?? "No Name"
                        })
                        .onSubmit {
                            guard firebaseHelper.playerState != nil, firebaseHelper.playerState!.name != name else {
                                return
                            }
                            
                            Task {
                                await firebaseHelper.updatePlayer(["name": name])
                            }
                        }
                    Divider()
                    TeamPicker()
                        .frame(width: 35)
                    Divider()
                    TeamColorPicker()
                        .frame(width: 35)
                }
                .frame(width: specs.maxX * 0.6, height: 22)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .stroke(Color("OffWhite"), lineWidth: 1.0)
                        .frame(width: specs.maxX * 0.66, height: 40)
                )
                .onChange(of: isFocused, {
                    withAnimation {
                        isEditing = isFocused
                    }
                })
            
            
            // for preview
//                if firebaseHelper.teams == [] {
//                    HStack(spacing: 20) {
//                        VStack {
//                            Text("Team \(TeamState.team_one.team_num)")
//                                .font(.custom("LuckiestGuy-Regular", size: 20))
//                                .offset(y: 2)
//                                .padding(6)
//                                .foregroundStyle(Color(TeamState.team_one.color))
//                                .shadow(radius: 5)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 30)
//                                        .stroke(Color(TeamState.team_one.color), lineWidth: 1.3)
//                                        .offset(y: -25)
//                                        .clipped()
//                                        .offset(y: 22)
//                                        .shadow(radius: 5)
//                                }
//                            Text("Dan")
//                                .foregroundStyle(Color.theme.white)
//                                .font(.custom("LuckiestGuy-Regular", size: 18))
//                                .offset(y: 1.8)
//                            Text("Katie")
//                                .foregroundStyle(Color.theme.white)
//                                .font(.custom("LuckiestGuy-Regular", size: 18))
//                                .offset(y: 1.8)
//                        }
//                        .frame(height: 100, alignment: .top)
//                        
//                        VStack {
//                            Text("Team \(TeamState.team_two.team_num)")
//                                .font(.custom("LuckiestGuy-Regular", size: 20))
//                                .offset(y: 2)
//                                .padding(6)
//                                .foregroundStyle(Color(TeamState.team_two.color))
//                                .shadow(color: .black, radius: 1)
//                                .background {
//                                    RoundedRectangle(cornerRadius: 30)
//                                        .stroke(Color(TeamState.team_two.color), lineWidth: 1.3)
//                                        .offset(y: -25)
//                                        .clipped()
//                                        .offset(y: 22)
//                                        .shadow(radius: 1)
//                                }
//                            Text("Ben")
//                                .foregroundStyle(Color.theme.white)
//                                .font(.custom("LuckiestGuy-Regular", size: 18))
//                                .offset(y: 1.8)
//                            Text("Alex")
//                                .foregroundStyle(Color.theme.white)
//                                .font(.custom("LuckiestGuy-Regular", size: 18))
//                                .offset(y: 1.8)
//                        }
//                        .frame(height: 100, alignment: .top)
//                    }
//                } else {
                    HStack(spacing: 20) {
                        ForEach(firebaseHelper.teams.sorted(by: { $0.team_num < $1.team_num }), id:\.self) { team in
                            VStack {
                                Text("Team \(team.team_num)")
                                    .font(.custom("LuckiestGuy-Regular", size: 20))
                                    .offset(y: 2)
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
                                ForEach(firebaseHelper.players.filter { $0.team_num == team.team_num }, id: \.self) { player in
                                    Text(player.name)
                                        .foregroundStyle(Color.theme.white)
                                        .font(.custom("LuckiestGuy-Regular", size: 18))
                                        .offset(y: 1.8)
                                }
                            }
                            .frame(height: 100, alignment: .top)
                        }
                    }
//                }
                
                if firebaseHelper.playerState?.is_lead ?? true {
                    Button {
                        Task {
                            await firebaseHelper.reorderPlayerNumbers()
                            await firebaseHelper.updateGame(["is_playing": true, "turn": 1])
                        }
                    } label: {
                        Text("Play!")
                            .padding()
                            .foregroundStyle(Color.white)
                            .font(.custom("LuckiestGuy-Regular", size: 25))
                            .offset(y: 2.2)
                    }
                    .disabled(!equalNumOfPlayersOnTeam(players: firebaseHelper.players))
                    
    //                Button("Play!") {
    //                    Task {
    //                        await firebaseHelper.reorderPlayerNumbers()
    //                        await firebaseHelper.updateGame(["is_playing": true, "turn": 1])
    //                    }
    //                }
    //                .buttonStyle(.borderedProminent)
    //                .disabled(!equalNumOfPlayersOnTeam(players: firebaseHelper.players))
                } else {
                    Text("Waiting to start game...")
                        .foregroundStyle(Color.theme.white)
                        .font(.custom("LuckiestGuy-Regular", size: 18))
                        .offset(y: 1.8)
                }
            }
            .padding(25)
            .getSize(onChange: { newSize in
                withAnimation {
                    size = newSize
                }
            })
        }
        .onTapGesture {
            endTextEditing()
        }
    }
    
    func determineFrameWidth(geo: GeometryProxy) -> Double {
        var width: Double = 0.0
        
        if isEditing {
            width = geo.frame(in: .local).width * 0.66
        } else {
            if name.isEmpty {
                width = geo.frame(in: .local).width * 0.33
            } else {
                width = max(name.width(usingFont: UIFont.systemFont(ofSize: 15)) + 35, geo.frame(in: .local).width * 0.33)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!equalNumOfPlayersOnTeam(players: firebaseHelper.players))
        } else {
            Text("Waiting to start game...")
        }
        
        return width
    }
}

func equalNumOfPlayersOnTeam(players: [PlayerState]) -> Bool {
    if players.count < 2 {
        return false
    } else {
        var numOfPlayers = [0,0,0]
        for player in players {
            numOfPlayers[player.team_num - 1] += 1
        }
        // if third team has no players, or the count is equal to another team
        return numOfPlayers[0] == numOfPlayers[1] && (numOfPlayers[2] == 0 || numOfPlayers[0] == numOfPlayers[2])
    }
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
