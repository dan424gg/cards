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
            Text("Cards")
                .font(.headline)
            if cardsInHand.count < 5 {
                HStack(alignment: .center, content: {
                    ForEach(cardsInHand, id: \.self) { card in
                        if isDisabled {
                            DisabledCardView(cardItem: card)
                        } else {
                            CardView(cardItem: card)
                        }
                    }
                })
            } else {
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack(alignment: .center, content: {
                        ForEach(cardsInHand, id: \.self) { card in
                            if isDisabled {
                                DisabledCardView(cardItem: card)
                            } else {
                                CardView(cardItem: card)
                            }
                        }
                    })
                })
            }
        }
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

#Preview {
    CardInHandArea(isDisabled: .constant(true), cardsDragged: .constant([CardItem(id: 0, card: "HA"), CardItem(id: 1, card: "JK")]), cardsInHand: .constant([CardItem(id: 0, card: "DJ"), CardItem(id: 1, card: "D5"), CardItem(id: 2, card: "SA")]))
}
