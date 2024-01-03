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
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    @State var cardIsDisabled = false
    
    @State private var firstDropAreaBorderColor: Color = .clear
    @State private var firstDropAreaBorderWidth: CGFloat = 1.0
    @State private var secondDropAreaBorderColor: Color = .clear
    @State private var secondDropAreaBorderWidth: CGFloat = 1.0
    
    var body: some View {
        VStack {
            switch (firebaseHelper.gameState?.num_players ?? 4) {
            case 2:
                HStack {
                    if cardsDragged.count == 0 {
                        CardPlaceHolder()
                            .border(firstDropAreaBorderColor, width: firstDropAreaBorderWidth)
                            .dropDestination(for: CardItem.self) { items, location in
                                cardsDragged.append(items.first!.id)
                                cardsInHand.removeAll(where: { card in
                                    card == items.first!.id
                                })
                                return true
                            } isTargeted: { inDropArea in
                                firstDropAreaBorderColor = inDropArea ? .green : .clear
                                firstDropAreaBorderWidth = inDropArea ? 7.0 : 1.0
                            }
                        CardPlaceHolder()
                            .border(secondDropAreaBorderColor, width: secondDropAreaBorderWidth)
                            .dropDestination(for: CardItem.self) { items, location in
                                cardsDragged.append(items.first!.id)
                                cardsInHand.removeAll(where: { card in
                                    card == items.first!.id
                                })
                                return true
                            } isTargeted: { inDropArea in
                                secondDropAreaBorderColor = inDropArea ? .green : .clear
                                secondDropAreaBorderWidth = inDropArea ? 7.0 : 1.0
                            }
                    } 
//                    else {
//                        if cardsDragged.count == 1 {
//                            CardView(cardItem: CardItem(id: cardsDragged[0]), cardIsDisabled: .constant(true))
//                            CardPlaceHolder()
//                                .border(secondDropAreaBorderColor, width: secondDropAreaBorderWidth)
//                                .dropDestination(for: CardItem.self) { items, location in
//                                    cardsDragged.append(items.first!)
//                                    cardsInHand.removeAll(where: { card in
//                                        card == items.first!
//                                    })
//                                    return true
//                                } isTargeted: { inDropArea in
//                                    secondDropAreaBorderColor = inDropArea ? .green : .clear
//                                    secondDropAreaBorderWidth = inDropArea ? 7.0 : 1.0
//                                }
//                            
//                        } else {
//                            CardView(cardItem: CardItem(id: cardsDragged[0]), cardIsDisabled: .constant(true))
//                            CardView(cardItem: CardItem(id: cardsDragged[1]), cardIsDisabled: .constant(true))
//                        }
//                    }
                }
//            case 3,4:
//                if cardsDragged.count == 0 {
//                    CardPlaceHolder()
//                        .border(firstDropAreaBorderColor, width: firstDropAreaBorderWidth)
//                        .dropDestination(for: CardItem.self) { items, location in
//                            cardsDragged.append(items.first!)
//                            cardsInHand.removeAll(where: { card in
//                                card == items.first!
//                            })
//                            return true
//                        } isTargeted: { inDropArea in
//                            firstDropAreaBorderColor = inDropArea ? .green : .clear
//                            firstDropAreaBorderWidth = inDropArea ? 7.0 : 1.0
//                        }
//                } else {
//                    CardView(cardItem: CardItem(id: cardsDragged[0]), cardIsDisabled: .constant(true))
//                }
//            case 6:
//                let dealer = firebaseHelper.players.first(where: { player in
//                    player.player_num == firebaseHelper.gameState?.dealer
//                })
//                
//                if (firebaseHelper.playerState?.player_num == firebaseHelper.gameState?.dealer)
//                    /* or if player is "to the left" of the dealer */
//                    || ((firebaseHelper.playerState?.player_num! ?? 1 + 1) % (firebaseHelper.gameState?.num_players ?? 2)) != (dealer?.player_num! ?? 1) {
//                    Text("Waiting for players to discard...")
//                } else {
//                    if cardsDragged.count == 0 {
//                        CardPlaceHolder()
//                            .border(firstDropAreaBorderColor, width: firstDropAreaBorderWidth)
//                            .dropDestination(for: CardItem.self) { items, location in
//                                cardsDragged.append(items.first!)
//                                cardsInHand.removeAll(where: { card in
//                                    card == items.first!
//                                })
//                                return true
//                            } isTargeted: { inDropArea in
//                                firstDropAreaBorderColor = inDropArea ? .green : .clear
//                                firstDropAreaBorderWidth = inDropArea ? 7.0 : 1.0
//                            }
//                    } else {
//                        CardView(cardItem: cardsDragged[0], cardIsDisabled: .constant(true))
//                    }
//                }
            default:
                Text("don't get here")
            }
        }
        .frame(height: 100)
        .onChange(of: firebaseHelper.players) {
            if firebaseHelper.playerState!.is_lead! && firebaseHelper.checkIfPlayersAreReady() {
                Task {
                    await firebaseHelper.updateGame(newState: ["turn": firebaseHelper.gameState!.turn + 1])
                }
            }
        }
        .onChange(of: cardsDragged) {
            if playerReady() {
                cardIsDisabled = true

                firebaseHelper.updatePlayer(newState: [
                    "cards_in_hand": cardsInHand,
                    "is_ready": true
                ])
                
//                let teamWithCrib = firebaseHelper.teams.first(where: { team in
//                    team.has_crib
//                })

                firebaseHelper.updateTeam(newState: ["crib": cardsDragged])
            }
        }
    }
    
    func playerReady() -> Bool {
        switch (firebaseHelper.gameState?.num_teams ?? 2) {
        case 2: return cardsDragged.count == 2
        case 3: 
            if firebaseHelper.gameState!.num_players == 3 {
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
    TurnOneView(cardsDragged: .constant([0]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
