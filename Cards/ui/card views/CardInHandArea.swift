//
//  CardInHandArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI

extension AnyTransition {
    static func custom(index: Int) -> AnyTransition {
        AnyTransition
            .move(edge: .bottom)
            .animation(.default.delay(0.5 * Double(index)))
    }
}

struct CardInHandArea: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    
    var showBackside = false
    
    @State var firstTurn = false

    var body: some View {
        VStack {
            ZStack {
                if firstTurn {
                    ForEach(Array(cardsInHand.enumerated()), id: \.offset) { (index, cardId) in
                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: showBackside)
                            .offset(y: -50)
                            .rotationEffect(.degrees(-Double((cardsInHand.count - 1) * 6) + Double(index * 12)))
                    }
                }
            }
            .onChange(of: firebaseHelper.playerState!.cards_in_hand, initial: true, {
                cardsInHand = firebaseHelper.playerState!.cards_in_hand!
            })
            .onAppear(perform: {
                firstTurn.toggle()
            })
            .offset(y: 50)
            .dropDestination(for: CardItem.self) { items, location in
                if !cardsInHand.contains(items.first!.id) {
//                    updatePlayer(newState: ["cards_in_hand": items], uid: <#T##String?#>, cardAction: <#T##CardUpdateType?#>)
                    cardsDragged.removeAll(where: { card in
                        card == items.first!.id
                    })
                }
                return true
            }
            .padding()
        }

    }
}

#Preview {
    CardInHandArea(cardsDragged: .constant([]), cardsInHand: .constant(Array(0...4)))
        .environmentObject(FirebaseHelper())
}
