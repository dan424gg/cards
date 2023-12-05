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
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    var showBackside = false
    
    @State var firstTurn = false

    var body: some View {
        VStack {
            ZStack {
                if firstTurn {
                    ForEach(Array(cardsInHand.enumerated()), id: \.offset) { (index, card) in
                        CardView(cardItem: card, cardIsDisabled: .constant(false), backside: showBackside)
                            .offset(y: -50)
                            .rotationEffect(.degrees(-Double((cardsInHand.count - 1) * 6) + Double(index * 12)))
                    }
//                    .transition(.move(edge: .bottom))
                }
            }
//            .animation(.default.delay(2.0), value: firstTurn)
            .onAppear(perform: {
                firstTurn.toggle()
            })
            
            .offset(y: 50)
            .dropDestination(for: CardItem.self) { items, location in
                if !cardsInHand.contains(items.first!) {
                    cardsInHand.append(items.first!)
                    cardsDragged.removeAll(where: { card in
                        card == items.first!
                    })
                }
                return true
            }
            .padding()
        }

    }
}

#Preview {
    CardInHandArea(cardsDragged: .constant([]), cardsInHand: .constant([CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond"), CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")]))
        .environmentObject(FirebaseHelper())
}
