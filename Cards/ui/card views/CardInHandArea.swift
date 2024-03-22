//
//  CardInHandArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI


struct CardInHandArea: View {
    @Environment(\.namespace) var namespace
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    
    @State var temp: [Int] = []
        
    var showBackside = false

    var body: some View {
        ZStack {
            if cardsInHand == [-1] {
                ForEach(Array(firebaseHelper.playerState?.cards_in_hand.enumerated() ?? [].enumerated()), id: \.offset) { (index, cardId) in
                    CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: .constant(showBackside))
                        .matchedGeometryEffect(id: cardId, in: namespace)
//                        .transition(.scale.combined(with: .opacity))
                        .offset(y: -50)
                        .scaleEffect(x: 2, y: 2)
                        .rotationEffect(.degrees(-Double((firebaseHelper.playerState!.cards_in_hand.count - 1) * 6) + Double(index * 12)))
                }
            } else {
                ForEach(Array(cardsInHand.enumerated()), id: \.offset) { (index, cardId) in
                    CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: .constant(showBackside))
                        .matchedGeometryEffect(id: cardId, in: namespace)
//                        .transition(.scale.combined(with: .opacity))
                        .offset(y: -50)
                        .scaleEffect(x: 2, y: 2)
                        .rotationEffect(.degrees(-Double((firebaseHelper.playerState!.cards_in_hand.count - 1) * 6) + Double(index * 12)))
                }
            }
        }
//            .dropDestination(for: CardItem.self) { items, location in
//                if !cardsInHand.contains(items.first!.id) {
//                    cardsInHand.append(items.first!.id)
//                    cardsDragged.removeAll(where: { card in
//                        card == items.first!.id
//                    })
//                }
//                return true
//            }
//            .padding()
    }
}

#Preview {
    CardInHandArea(cardsDragged: .constant([]), cardsInHand: .constant(Array(0...4)))
        .environmentObject(FirebaseHelper())
}
