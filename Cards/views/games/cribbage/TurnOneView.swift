//
//  CardDropArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI
import FirebaseFirestore

struct TurnOneView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    @State var cardIsDisabled = false
    
    @State private var firstDropAreaBorderColor: Color = .clear
    @State private var firstDropAreaBorderWidth: CGFloat = 1.0
    @State private var secondDropAreaBorderColor: Color = .clear
    @State private var secondDropAreaBorderWidth: CGFloat = 1.0
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                if cardsDragged.count > 0 {
                    CardView(cardItem: cardsDragged[0], cardIsDisabled: $cardIsDisabled)
                } else {
                    CardPlaceHolder()
                        .border(firstDropAreaBorderColor, width: firstDropAreaBorderWidth)
                        .dropDestination(for: CardItem.self) { items, location in
                            if !cardsDragged.contains(items.first!) {
                                cardsDragged.append(items.first!)
                                cardsInHand.removeAll(where: { card in
                                    card == items.first!
                                })
                            }
                            return true
                        } isTargeted: { inDropArea in
                            firstDropAreaBorderColor = inDropArea ? .green : .clear
                            firstDropAreaBorderWidth = inDropArea ? 7.0 : 1.0
                        }
                }
                
                if firebaseHelper.gameInfo?.num_teams ?? 2 == 2 {
                    if cardsDragged.count > 1 {
                        CardView(cardItem: cardsDragged[1], cardIsDisabled: $cardIsDisabled)
                    } else {
                        CardPlaceHolder()
                            .border(secondDropAreaBorderColor, width: secondDropAreaBorderWidth)
                            .dropDestination(for: CardItem.self) { items, location in
                                if !cardsDragged.contains(items.first!) {
                                    cardsDragged.append(items.first!)
                                    cardsInHand.removeAll(where: { card in
                                        card == items.first!
                                    })
                                }
                                return true
                            } isTargeted: { inDropArea in
                                secondDropAreaBorderColor = inDropArea ? .green : .clear
                                secondDropAreaBorderWidth = inDropArea ? 7.0 : 1.0
                            }
                    }
                }
            }
        }
        .frame(height: 100)
        .onAppear(perform: {
            Task {
                await firebaseHelper.shuffleAndDealCards(cardsInHand_binding: $cardsInHand)
            }
        })
        .onChange(of: cardsDragged) {
            if playerReady() {
                cardIsDisabled = true

                firebaseHelper.updatePlayer(newState: [
                    "cards_in_hand": cardsInHand
                ])
                
                let teamWithCrib = firebaseHelper.teams.first(where: { team in
                    team.has_crib
                })
                
                firebaseHelper.updateTeam(newState: ["crib": cardsDragged], team: teamWithCrib?.team_num)
            }
        }
    }
    
    func playerReady() -> Bool {
        switch (firebaseHelper.gameInfo?.num_teams ?? 2) {
        case 2: return cardsDragged.count == 2
        case 3: 
            if firebaseHelper.playerInfo?.cards_in_hand!.count == 5 {
                return cardsDragged.count == 1
            } else {
                return cardsDragged.count == 0
            }
        default:
            return false
        }
    }
}

#Preview {
    TurnOneView(cardsDragged: .constant([CardItem(id: 0, value: "A", suit: "H")]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
