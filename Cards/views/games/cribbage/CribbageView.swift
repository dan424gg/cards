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
    @State var isUiDisabled: Bool = false
    @State var showSnackbar: Bool = false
    @State var cardsDragged: [CardItem] = []
    @State var cardsInHand: [CardItem] = []
    
    var body: some View {
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
                
            case 2: TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                    .task {
                        isUiDisabled = false
                        firebaseHelper.updatePlayer(newState: ["is_ready": false])
                        if firebaseHelper.playerInfo!.is_lead {
                            firebaseHelper.updateGame(newState: ["is_ready": false])
                        }
                    }
                    .onAppear(perform: {
                        cardsDragged = []
                        if firebaseHelper.playerInfo != nil && firebaseHelper.playerInfo!.cards_in_hand != [] {
                            cardsInHand = firebaseHelper.playerInfo!.cards_in_hand
                        } else {
                            cardsInHand = players[0].cards_in_hand
                        }
                    })
                    .transition(.slide)
            default:
                EmptyView()
            }
            Spacer().frame(height: 95)
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
//                    Button(isUiDisabled ? "Not Ready!" : "Ready!") {
//                        if cardsDragged.count == 2 {
//                            showSnackbar = false
//                            isUiDisabled = !isUiDisabled
//                            Task {
//                                firebaseHelper.updatePlayer(newState: [
//                                    "is_ready": isUiDisabled,
//                                    "cards_in_hand": cardsInHand
//                                ])
//                                if controller.moveToNextRound(players: firebaseHelper.players) {
//                                    firebaseHelper.updateGame(newState: [
//                                        "is_ready": true,
//                                        "turn": ((firebaseHelper.gameInfo?.turn ?? game.turn) + 1)
//                                    ])
//                                }
//                            }
//                        } else {
//                            showSnackbar = true
//                        }
//                    }
//                    .buttonStyle(.bordered)
            .snackbar(isShowing: $showSnackbar, title: "Not Ready", text: "You need to select two cards to discard!", style: .warning)
        }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
        Cribbage()
            .environmentObject(FirebaseHelper())
    }
}
