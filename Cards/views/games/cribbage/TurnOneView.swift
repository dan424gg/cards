//
//  CardDropArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI
import FirebaseFirestore

struct TurnOneView: View {
    @Environment(GameHelper.self) private var gameHelper
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    @State var cardIsDisabled = false
    
    @State private var firstDropAreaBorderColor: Color = .clear
    @State private var firstDropAreaBorderWidth: CGFloat = 1.0
    @State private var secondDropAreaBorderColor: Color = .clear
    @State private var secondDropAreaBorderWidth: CGFloat = 1.0
    
    var body: some View {
        VStack {
            switch (gameHelper.gameState?.num_players ?? 4) {
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
                        } else {
                            if cardsDragged.count == 1 {
                                CardView(cardItem: CardItem(id: cardsDragged[0]), cardIsDisabled: .constant(true), backside: .constant(false))
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

                            } else {
                                CardView(cardItem: CardItem(id: cardsDragged[0]), cardIsDisabled: .constant(true), backside: .constant(false))
                                CardView(cardItem: CardItem(id: cardsDragged[1]), cardIsDisabled: .constant(true), backside: .constant(false))
                            }
                        }
                    }
                case 3,4:
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
                    } else {
                        CardView(cardItem: CardItem(id: cardsDragged[0]), cardIsDisabled: .constant(true), backside: .constant(false))
                    }
                case 6:
                    if (gameHelper.playerState!.player_num == gameHelper.gameState?.dealer) ||
                        ((gameHelper.playerState!.player_num + 1) % (gameHelper.gameState!.num_players)) != (gameHelper.gameState?.dealer ?? 1) {
                        CText("Waiting for players to discard...")
                    } else {
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
                        }
                        else {
                            CardView(cardItem: CardItem(id: cardsDragged[0]), cardIsDisabled: .constant(true), backside: .constant(false))
                        }
                    }
                default:
                    CText("don't get here")
            }
        }
        .frame(height: 100)
        .onChange(of: cardsDragged) {            
            if playerReady() {
                cardIsDisabled = true

                Task {
                    await gameHelper.updatePlayer([
                        "cards_in_hand": cardsDragged,
                        "is_ready": true
                    ], arrayAction: .remove)
                    
                    await gameHelper.updateGame(["crib": cardsDragged], arrayAction: .append)
                }
            }
        }
        .onDisappear {
            cardsDragged = []
        }
    }
    
    func playerReady() -> Bool {
        guard gameHelper.gameState != nil, gameHelper.playerState != nil else {
            return false
        }
        
        switch (gameHelper.gameState!.num_teams) {
            case 2: return gameHelper.gameState!.num_players == 2 ? cardsDragged.count == 2 : cardsDragged.count == 1
            case 3:
                if gameHelper.gameState!.num_players == 3 {
                    return cardsDragged.count == 1
                } else {
                    // if player is dealer or to the left of the dealer
                    if (gameHelper.playerState!.player_num == gameHelper.gameState!.dealer ||
                        ((gameHelper.playerState!.player_num + 1) % gameHelper.gameState!.num_players) == gameHelper.gameState!.dealer) {
                        return true
                    } else {
                        return cardsDragged.count == 1
                    }
                }
            default:
                return false
            }
    }
}

#Preview {
    TurnOneView(cardsDragged: .constant([0]), cardsInHand: .constant([]))
        .environment(GameHelper())
}
