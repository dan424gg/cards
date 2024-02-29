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
        VStack {
            VStack {
                Text(String(firebaseHelper.gameState?.group_id ?? 12345))
                    .font(.system(size: 15))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .stroke(.green, lineWidth: 1.0)
                    )
                    
                GamePicker()
                    .font(.system(size: 15))
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)
                            .stroke(.green, lineWidth: 1.0)
                    )
                
                HStack {
                    TextField("Name", text: $name)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .focused($isFocused)
                    Divider()
                    TeamPicker()
                        .frame(width: 35)
                    Divider()
                    TeamColorPicker()
                        .frame(width: 35)
                }
                .frame(width: specs.maxX * 0.6, height: 22)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .stroke(.green, lineWidth: 1.0)
                        .frame(width: specs.maxX * 0.66, height: 40)
                )
                .onChange(of: isFocused, {
                    withAnimation {
                        isEditing = isFocused
                    }
                })
            }
            
            VStack {
                HStack {
                    // for preview
                    if firebaseHelper.teams == [] {
                        VStack {
                            HStack {
//                                TeamColorPicker()
                                VStack {
                                    Text("Team \(TeamState.team_one.team_num)")
                                        .font(.system(size: 15))
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 30)
                                                .fill(.white)
                                                .stroke(Color(TeamState.team_one.color), lineWidth: 1.0)
                                        )
                                    Text("Dan")
                                    Text("Katie")
                                }
                            }
                        }
                        
                        VStack {
                            Text("Team \(TeamState.team_two.team_num)")
                                .font(.system(size: 15))
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color(TeamState.team_two.color), lineWidth: 1.0)
                                )
                            Text("Ben")
                            Text("Alex")
                        }
                    } else {
                        ForEach(firebaseHelper.teams.sorted(by: { $0.team_num < $1.team_num }), id:\.self) { team in
                            VStack {
                                HStack {
                                    Text("Team \(team.team_num)")
                                        .font(.system(size: 15))
                                        .padding(10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 30)
                                                .fill(.white)
                                                .stroke(Color(team.color), lineWidth: 1.0)
                                        )
                                }
                                
                                ForEach(firebaseHelper.players, id:\.self) { player in
                                    if player.team_num == team.team_num {
                                        Text(player.name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if firebaseHelper.playerState?.is_lead ?? false {
                GameStartButton()
            } else {
                Text("Waiting to start game...")
            }
        }
        .onAppear {
            size = CGSize(width: specs.maxX * 0.66, height: specs.maxY * 0.4)
        }
        .frame(width: specs.maxX * 0.66, height: specs.maxY * 0.4)
        .position(x: specs.maxX / 2, y: size.height / 2)
//        .getSize(onChange: {
//            print("load: \($0)")
//            if size == .zero {
//                size = $0
//            }
//        })
        .onTapGesture {
            endTextEditing()
        }
//        .fullScreenCover(isPresented: Binding(
//            get: { firebaseHelper.gameState?.is_playing ?? false },
//            set: {_ in }
//        )) {
//            GameView()
//        }
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
    }
    .ignoresSafeArea()
}
