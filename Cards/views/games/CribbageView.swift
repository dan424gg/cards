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
    @State var cardDragged: CardItem?
    @State private var borderColor: Color = .blue
    @State private var borderWidth: CGFloat = 1.0

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
            
            Canvas { (context, size) in
                let rect = CGRect(origin: .zero, size: size)
                if let symbol = context.resolveSymbol(id: 1) {
                    let newRect = CGRect(origin: .zero, size: symbol.size)
                    context.draw(symbol, in: newRect)
                }
            } symbols: {
                if cardDragged != nil {
                    CardView(cardItem: cardDragged!)
                        .tag(1)
                }
            }
            .dropDestination(for: CardItem.self) { items, location in
                cardDragged = items.first
                print(location)
                return true
            } isTargeted: { inDropArea in
                borderColor = inDropArea ? .green : .blue
                borderWidth = inDropArea ? 7.0 : 1.0
            }
            .frame(width: 300, height: 200)
            .border(borderColor, width: borderWidth)
            
            Text("cards")
                .font(.headline)
            HStack {
                ForEach(players[0].cards_in_hand, id: \.self) { card in
                    CardView(cardItem: card)
                }
            }
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
