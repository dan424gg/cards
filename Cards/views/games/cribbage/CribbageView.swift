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
            switch(firebaseHelper.gameInfo?.turn ?? game.turn) {
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
            
            CardInHandArea(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                .offset(y: 50)
                .scaleEffect(x: 2, y: 2)
                .onAppear(perform: {
                    cardsInHand = [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond"), CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")]
                })
        }
    }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
        Cribbage(cardsDragged: .constant([CardItem(id: 39, value: "A", suit: "club")]), cardsInHand: .constant([]))
            .environmentObject(FirebaseHelper())
    }
}
