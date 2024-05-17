//
//  DisplayPointsInHand.swift
//  Cards
//
//  Created by Daniel Wells on 4/2/24.
//

import SwiftUI

struct PointContainer: View {
    @Environment(GameHelper.self) private var gameHelper
    @State var teamColor: Color = .purple
    @State var playerPoints: Int = -1
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
    
    var player: PlayerState = PlayerState()
    var user: Bool = false
    var crib: Bool = false
    
    var body: some View {
        ZStack {
            if playerPoints != -1 {
                CText("+ \(playerPoints)", size: user ? 56 : 16)
                    .foregroundStyle(teamColor)
//                    .font(.custom("LuckiestGuy-Regular", size: user ? 56 : 16))
                    .frame(minWidth: user ? 94 : 31, minHeight: user ? 56 : 16)
//                    .offset(y: user ? 7 : 2)
                    .padding(user ? 7.0 : 2.0)
                    .background(content: {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(teamColor, lineWidth: user ? 5.0 : 2.0)
                            .background { VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial)).clipShape(RoundedRectangle(cornerRadius: 5)) }
                    })
            }
        }
        .onAppear {
            guard (player != PlayerState()) ^ (crib != false) else {
                return
            }
            
            if crib {
                if let gameState = gameHelper.gameState {
                    if let team = gameHelper.teams.first(where: { $0.team_num == gameState.team_with_crib }) {
                        teamColor = Color("\(team.color)")
                    
                        let scoringHands = gameHelper.checkCardsForPoints(crib: gameState.crib, gameState.starter_card)
                        if let lastScoringHand = scoringHands.last {
                            playerPoints = lastScoringHand.cumlativePoints
                        } else {
                            playerPoints = 0
                        }
                        
                        // add points to team with crib, ensure it only happens once with lead player check
                        guard gameHelper.playerState != nil, gameHelper.playerState!.is_lead else {
                            return
                        }
                        
                        Task {
                            await gameHelper.updateTeam(["points": playerPoints + team.points], team.team_num)
                        }
                    }
                }
            } else {
                if let gameState = gameHelper.gameState {
                    if let team = gameHelper.teams.first(where: { $0.team_num == player.team_num }) {
                        teamColor = Color("\(team.color)")
                        
                        let scoringHands = gameHelper.checkCardsForPoints(playerCards: player.cards_in_hand, gameState.starter_card)
                        
                        if let lastScoringHand = scoringHands.last {
                            playerPoints = lastScoringHand.cumlativePoints
                        } else {
                            playerPoints = 0
                        }
                        
                        guard gameHelper.playerState != nil, gameHelper.playerState!.player_num == player.player_num else {
                            return
                        }
                        
                        
                        Task {
                            await gameHelper.updateTeam(["points": playerPoints + team.points])
                        }
                    }
                } else {
                    if let team = [TeamState.team_one, TeamState.team_two, TeamState.team_three].first(where: { $0.team_num == player.team_num }) {
                        teamColor = Color("\(team.color)")
                    }
                    
                    let scoringHands = gameHelper.checkCardsForPoints(playerCards: player.cards_in_hand, gameObservable.game.starter_card)
                    
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
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
