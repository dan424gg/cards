//
//  DisplayPointsInHand.swift
//  Cards
//
//  Created by Daniel Wells on 4/2/24.
//

import SwiftUI

struct PointContainer: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var teamColor: Color = .purple
    @State var playerPoints: Int = -1
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
    
    var player: PlayerState = PlayerState()
    var user: Bool = false
    var crib: Bool = false
    
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
            guard (player != PlayerState()) ^ (crib != false) else {
                return
            }
            
            if crib {
                if let gameState = firebaseHelper.gameState {
                    if let team = firebaseHelper.teams.first(where: { $0.team_num == gameState.team_with_crib }) {
                        teamColor = Color("\(team.color)")
                        print("found the team")
                    
                        let scoringHands = firebaseHelper.checkCardsForPoints(crib: gameState.crib, gameState.starter_card)
                        print("scoringPlays: \(scoringHands)")

                        if let lastScoringHand = scoringHands.last {
                            playerPoints = lastScoringHand.cumlativePoints
                        } else {
                            playerPoints = 0
                        }
                        
                        // add points to team with crib, ensure it only happens once with lead player check
                        guard firebaseHelper.playerState != nil, firebaseHelper.playerState!.is_lead else {
                            return
                        }
                        
                        Task {
                            await firebaseHelper.updateTeam(["points": playerPoints + team.points], team.team_num)
                        }
                    }
                }
            } else {
                if let gameState = firebaseHelper.gameState {
                    if let team = firebaseHelper.teams.first(where: { $0.team_num == player.team_num }) {
                        teamColor = Color("\(team.color)")
                        
                        let scoringHands = firebaseHelper.checkCardsForPoints(player: player, gameState.starter_card)
                        
                        if let lastScoringHand = scoringHands.last {
                            playerPoints = lastScoringHand.cumlativePoints
                        } else {
                            playerPoints = 0
                        }
                        
                        guard firebaseHelper.playerState != nil, firebaseHelper.playerState!.player_num == player.player_num else {
                            return
                        }
                        
                        print("sent points to team \(team.team_num)")
                        
                        Task {
                            await firebaseHelper.updateTeam(["points": playerPoints + team.points])
                        }
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
}

#Preview {
    return GeometryReader { geo in
        PointContainer()
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
