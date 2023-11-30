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
    var game = GameInformation(group_id: 1000, is_ready: false, is_won: false, num_teams: 2, turn: 1)
    
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                switch(firebaseHelper.gameInfo?.turn ?? game.turn) {
                case 1:
                    Text("The Deal")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                    Spacer().frame(height: 375)
                    TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                        .onAppear(perform: {
                            guard firebaseHelper.gameInfo != nil else {
                                return
                            }
                            if firebaseHelper.playerInfo!.is_lead! {
                                Task {
                                    await firebaseHelper.updateGame(newState: ["cards": GameInformation().cards.shuffled()])
                                }
                            }
                        })
                case 2:
                    Text("The Play")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                    Spacer().frame(height: 375)
                    TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                case 3:
                    Text("The Show")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                    Spacer().frame(height: 375)

                case 4:
                    Text("The Crib")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                    Spacer().frame(height: 375)

                default:
                    Text("Won't get here")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                }
            }
        }
    }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
        Cribbage(cardsDragged: .constant([CardItem(id: 39, value: "A", suit: "club")]), cardsInHand: .constant([]))
            .environmentObject(FirebaseHelper())
    }
}
