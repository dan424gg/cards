//
//  Cribbage.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI

struct Cribbage: View {
    var teams =  [TeamInformation.team_one, TeamInformation.team_two]
    var players = [PlayerInformation.player_one, PlayerInformation.player_two]
    var game = GameInformation(group_id: 1000, is_ready: false, is_won: false, num_players: 2, turn: 1)
    
    var controller = CribbageController()
    
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var buttonText: String = "Ready!"
    @State var isUiDisabled: Bool = false
    @State var cardsDragged: [CardItem] = []
    @State var cardsInHand: [CardItem] = []
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            VStack(spacing: 10) {
                Spacer()
                Text("Turn number \(firebaseHelper.gameInfo?.turn ?? game.turn)!")
                    .font(.title)
                    .onAppear(perform: {
                    })
                Divider()
                HStack(spacing: 20) {
                    if firebaseHelper.teams == [] {
                        ForEach(teams, id: \.self) { team in
                            VStack {
                                Text("Team \(team.team_num)")
                                Text("\(team.points)")
                            }
                            .font(.custom("", size: 21))
                            
                            if team != teams.last {
                                Divider()
                            }
                        }
                    } else {
                        ForEach(firebaseHelper.teams, id: \.self) { team in
                            VStack {
                                Text("Team \(team.team_num)")
                                Text("\(team.points)")
                            }
                            .font(.custom("", size: 21))
                            
                            if team != firebaseHelper.teams.last {
                                Divider()
                            }
                        }
                    }
                }
                Divider()
                HStack(spacing: 30) {
                    ShowStatus()
                }
            }
            
            VStack {
                switch(firebaseHelper.gameInfo?.turn ?? game.turn) {
                    case 0,1: TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                        .onAppear(perform: {
                            if firebaseHelper.playerInfo != nil && firebaseHelper.playerInfo!.cards_in_hand != [] {
                                cardsInHand = firebaseHelper.playerInfo!.cards_in_hand
                            } else {
                                cardsInHand = players[0].cards_in_hand
                            }
                        })
                        .transition(.slide)

                    case 2: TurnTwoView()
                        .task {
                            await firebaseHelper.updatePlayer(newState: ["is_ready": false])
                            if firebaseHelper.playerInfo!.is_lead {
                                firebaseHelper.updateGame(newState: ["is_ready": false])
                            }
                        }
                        .onAppear(perform: {
                            if firebaseHelper.playerInfo != nil && firebaseHelper.playerInfo!.cards_in_hand != [] {
                                cardsInHand = firebaseHelper.playerInfo!.cards_in_hand
                            } else {
                                cardsInHand = players[0].cards_in_hand
                            }
                        })
//                    case 3: break
//                    case 4: //
                    default:
                        EmptyView()
                }
                
                CardInHandArea(isDisabled: $isUiDisabled, cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                    .onAppear(perform: {
                        if firebaseHelper.playerInfo != nil && firebaseHelper.playerInfo!.cards_in_hand != [] {
                            cardsInHand = firebaseHelper.playerInfo!.cards_in_hand
                        } else {
                            cardsInHand = players[0].cards_in_hand
                        }
                    })
            }
            .disabled(isUiDisabled)
            
            Button(buttonText) {
                isUiDisabled = !isUiDisabled
                buttonText = isUiDisabled ? "Not Ready!" : "Ready!"
                Task {
                    await firebaseHelper.updatePlayer(newState: ["is_ready": isUiDisabled])
                    if controller.readyForNextRound(players: firebaseHelper.players) {
                        firebaseHelper.updateGame(newState: [
                            "is_ready": true,
                            "turn": ((firebaseHelper.gameInfo?.turn ?? game.turn) + 1)
                        ])
                    }
                }
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        
    }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
//        Text("nothing")
        Cribbage()
            .environmentObject(FirebaseHelper())
    }
}
