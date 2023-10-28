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
    var game = GameInformation(group_id: 1000, is_pregame: false, is_won: false, num_players: 2, turn: 1)
    
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var cardsDragged: [CardItem] = []
    @State var cardsInHand: [CardItem] = []


    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            VStack(spacing: 10) {
                Text("Turn number \(game.turn)!")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                HStack {
                    ForEach(teams, id: \.self) { team in
                        Text("\(team.points)")
                            .font(.largeTitle)
                    }
                }
                Divider()
                Spacer().frame(width: 10, height: 100)
            }
            
            CardDropArea(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
            CardInHandArea(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
            .onAppear(perform: {
                cardsInHand = players[0].cards_in_hand
            })
            
            Spacer()
        }
    }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
        Cribbage()
            .environmentObject(FirebaseHelper())
    }
}
