//
//  Cribbage.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI

struct Cribbage: View {
    var teams =  [TeamState.team_one, TeamState.team_two]
    var players = [PlayerState.player_one, PlayerState.player_two]
    var game = GameState(group_id: 1000, is_playing: false, is_won: false, num_teams: 2, turn: 1)
    
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    
    var body: some View {
        VStack {
            switch(firebaseHelper.gameState?.turn ?? game.turn) {
            case 1:
                Text("The Deal")
                    .font(.title3)
                    .foregroundStyle(.gray.opacity(0.7))
                TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
            case 2:
                Text("The Play")
                    .font(.title3)
                    .foregroundStyle(.gray.opacity(0.7))
                TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
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
            
            Button("increment turn") {
                Task {
                    await firebaseHelper.updateGame(newState: ["turn": ((firebaseHelper.gameState?.turn ?? 0) % 4) + 1])
                }
            }
            
            CardInHandArea(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                .offset(y: 50)
                .scaleEffect(x: 2, y: 2)
        }
        .onChange(of: firebaseHelper.gameState?.turn, {
            if firebaseHelper.gameState?.turn ?? 1 == 1 {
                cardsDragged = []
            }
        })
    }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
        Cribbage(cardsDragged: .constant([]), cardsInHand: .constant([]))
            .environmentObject(FirebaseHelper())
    }
}
