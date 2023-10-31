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
                    .font(.title)
                HStack(spacing: 20) {
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
                }
                Divider()
                HStack(spacing: 30){
                    ForEach(players, id: \.self) { player in
                        HStack {
                            Text(player.name)
                            StatusDot(is_ready: player.is_ready)
                        }
                    }
                }
                Spacer().frame(width: 10, height: 120)
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
