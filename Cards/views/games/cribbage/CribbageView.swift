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
    var game = GameInformation(group_id: 1000, is_ready: false, is_won: false, num_players: 2, turn: 2)
    
    var controller = CribbageController()
    
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var isUiDisabled: Bool = false
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                switch(firebaseHelper.gameInfo?.turn ?? game.turn) {
                case 1:
                    Text("The Deal")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                case 2:
                    Text("The Play")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                case 3:
                    Text("The Show")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                case 4:
                    Text("The Crib")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                default:
                    Text("Won't get here")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                }
            }
            Spacer().frame(height: 375)
            VStack {
                
                switch(firebaseHelper.gameInfo?.turn ?? game.turn) {
                case 0,1:
                    TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                        .transition(.slide)
                    
                case 2: TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                        .task {
                            isUiDisabled = false
                            firebaseHelper.updatePlayer(newState: 
                                    ["is_ready": false]
                            )
                            if firebaseHelper.playerInfo?.is_lead ?? false {
                                firebaseHelper.updateGame(newState:
                                    ["is_ready": false]
                                )
                            }
                        }
                        .transition(.slide)
                default:
                    EmptyView()
                }
            }
            .disabled(isUiDisabled)
            
            Button(isUiDisabled ? "Not Ready!" : "Ready!") {
                if cardsDragged.count == 2 {
                    isUiDisabled = !isUiDisabled
                    Task {
                        firebaseHelper.updatePlayer(newState: [
                            "is_ready": isUiDisabled,
                            "cards_in_hand": cardsInHand
                        ])
                        if controller.moveToNextRound(players: firebaseHelper.players) {
                            firebaseHelper.updateGame(newState: [
                                "is_ready": true,
                                "turn": ((firebaseHelper.gameInfo?.turn ?? game.turn) + 1)
                            ])
                        }
                    }
                } else {
                    firebaseHelper.sendWarning(w: "You need to discard two cards!")
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
        Cribbage(cardsDragged: .constant([CardItem(id: 39, value: "A", suit: "club")]), cardsInHand: .constant([]))
            .environmentObject(FirebaseHelper())
    }
}
