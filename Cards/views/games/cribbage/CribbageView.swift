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
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    var body: some View {
        VStack {
            switch(firebaseHelper.gameInfo?.turn ?? game.turn) {
            case 0,1: TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                    .transition(.slide)
                
            case 2: TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                    .task {
                        isUiDisabled = false
                        firebaseHelper.updatePlayer(newState: ["is_ready": false])
                        if firebaseHelper.playerInfo!.is_lead {
                            firebaseHelper.updateGame(newState: ["is_ready": false])
                        }
                    }
                    .transition(.slide)
            default:
                EmptyView()
            }
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
        Cribbage(cardsDragged: .constant([CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")]), cardsInHand: .constant([CardItem(id: 9, value: "10", suit: "spade"), CardItem(id: 10, value: "J", suit: "spade"),CardItem(id: 16, value: "4", suit: "heart"), CardItem(id: 17, value: "5", suit: "heart"),]))
            .environmentObject(FirebaseHelper())
    }
}
