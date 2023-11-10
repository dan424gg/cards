//
//  CardInHandArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI

struct CardInHandArea: View {
    @Binding var isDisabled: Bool
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    var body: some View {
        VStack {
            Text("Cards in hand")
                .font(.subheadline)
            if cardsInHand != [] {
                ZStack {
//                    Circle()
//                        .stroke(Color.red)
//                        .frame(width: 100, height:100)
                    ForEach(Array(cardsInHand.enumerated()), id: \.offset) { (index, card) in
                        if isDisabled {
                            //                            DisabledCardView(cardItem: card)
                        } else {
                            CardView(cardItem: card)
                                .rotationEffect(.degrees(-Double((cardsInHand.count - 1) * 5) + Double(index * 10)))
                                .onAppear(perform: {
                                    print(cardsInHand.count)
                                })
                        }
                    }
                }
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
}

#Preview {
    CardInHandArea(isDisabled: .constant(false), cardsDragged: .constant([]), cardsInHand: .constant([CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond"), CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")]))
}
