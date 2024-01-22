//
//  CardInHandArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI


struct CardInHandArea: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    
    var showBackside = false
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(Array(cardsInHand.enumerated()), id: \.offset) { (index, cardId) in
                    CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: showBackside)
                        .offset(y: -50)
                        .rotationEffect(.degrees(-Double((cardsInHand.count - 1) * 6) + Double(index * 12)))
                }
            }
            .onChange(of: firebaseHelper.playerState?.cards_in_hand, initial: true, {
                cardsInHand = firebaseHelper.playerState?.cards_in_hand ?? [1,2,3]
            })
            .offset(y: 50)
            .dropDestination(for: CardItem.self) { items, location in
                let tempCardArr = items.map { $0.id }
                
                if !cardsInHand.contains(items.first!.id) {
                    Task {
                        await firebaseHelper.updatePlayer(newState: ["cards_in_hand": tempCardArr], cardAction: .append)
                    }
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
