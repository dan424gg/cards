//
//  DisplayPointsInHand.swift
//  Cards
//
//  Created by Daniel Wells on 4/2/24.
//

import SwiftUI

struct DisplayPointsInHand: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State var multiplier = 0
    @State var startingRotation = 0
    
    var body: some View {
        if firebaseHelper.playerState == nil {
            ForEach(Array([PlayerState.player_one, PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six].enumerated()), id: \.offset) { (index, player) in
                if player.player_num == 5 {
                    PointContainer(player: .constant(player), user: true)
                        .rotationEffect(.degrees(-180.0))
                        .offset(y: -specs.maxY * 0.315)
                        .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        .zIndex(1.0)
                } else {
                    PointContainer(player: .constant(player))
//                        .rotationEffect(.degrees(-180.0))
                        .offset(y: -specs.maxY * 0.14)
                        .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        .zIndex(1.0)
                }
            }
            .onAppear {
                setMultiplierAndRotation()
            }
        } else {
            PointContainer(player: .constant(firebaseHelper.playerState!), user: true)
                .rotationEffect(.degrees(-180.0))
                .offset(y: -specs.maxY * 0.315)
                .zIndex(1.0)
            
            ForEach(Array($firebaseHelper.players.enumerated()), id: \.offset) { (index, player) in
                PointContainer(player: player)
                    .rotationEffect(.degrees(-180.0))
                    .offset(y: -specs.maxY * 0.14)
                    .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                    .zIndex(1.0)
            }
            .onAppear {
                setMultiplierAndRotation()
            }
        }
    }
    
    func setMultiplierAndRotation() {
        if let gameState = firebaseHelper.gameState {
            switch gameState.num_teams {
                case 2:
                    if gameState.num_players == 2 {
                        startingRotation = gameState.turn > 2 ? 180 : 0
                        multiplier = gameState.turn > 2 ? 180 : 0
                    } else {
                        startingRotation = gameState.turn > 2 ? 180 : 270
                        multiplier = 90
                    }
                case 3:
                    if gameState.num_players == 3 {
                        startingRotation = gameState.turn > 2 ? 180 : 300
                        multiplier = 120
                    } else {
                        startingRotation = gameState.turn > 2 ? 180 : 240
                        multiplier = 60
                    }
                default:
                    startingRotation = 0
                    multiplier = 0
            }
        } else {
            startingRotation = 240
            multiplier = 60
        }
    }
}

struct PointContainer: View {
    @Binding var player: PlayerState
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var teamColor: Color = .purple
    @State var playerPoints: Int = -1
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
    
    var user: Bool = false
    
    var body: some View {
        ZStack {
            if playerPoints != -1 {
                Text("+ \(playerPoints)")
                    .font(.custom("LuckiestGuy-Regular", size: user ? 56 : 16))
                    .frame(minWidth: user ? 94 : 31, minHeight: user ? 56 : 16)
                    .offset(y: user ? 9.0 : 2.85)
                    .padding(user ? 10.0 : 2.0)
                    .background(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.ultraThinMaterial)
                            .stroke(teamColor, lineWidth: user ? 5.0 : 2.0)
                    })
                    .foregroundStyle(teamColor)
            }
        }
        .onAppear {
            if let gameState = firebaseHelper.gameState {
                if let team = firebaseHelper.teams.first(where: { $0.team_num == player.team_num }) {
                    teamColor = Color("\(team.color)")
                }
                
                let scoringHands = firebaseHelper.checkCardsForPoints(player: player, gameState.starter_card)
                
                if let lastScoringHand = scoringHands.last {
                    playerPoints = lastScoringHand.cumlativePoints
                }
            } else {
                if let team = [TeamState.team_one, TeamState.team_two, TeamState.team_three].first(where: { $0.team_num == player.team_num }) {
                    teamColor = Color("\(team.color)")
                }
                
                let scoringHands = firebaseHelper.checkCardsForPoints(player: player, gameObservable.game.starter_card)
                
                if let lastScoringHand = scoringHands.last {
                    playerPoints = lastScoringHand.cumlativePoints
                }
            }
        }
    }
}

#Preview {
    return GeometryReader { geo in
        DisplayPointsInHand()
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
