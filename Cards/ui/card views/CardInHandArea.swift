//
//  CardInHandArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI

extension Animation {
    static func slide(index: Int) -> Animation {
        Animation.easeInOut(duration: 2.25)
            .delay(1.0 * Double(index))
    }
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.03 * Double(index))
    }
}

struct CardInHandArea: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    @State var doSomething: Bool = true
    
    var body: some View {
        VStack {
            if doSomething {
                ZStack {
                    ForEach(Array(cardsInHand.enumerated()), id: \.offset) { (index, card) in
                        CardView(cardItem: card, cardIsDisabled: .constant(false))
                            .offset(y: -50)
                            .rotationEffect(.degrees(-Double((cardsInHand.count - 1) * 6) + Double(index * 12)))
                            .animation(.slide(index: index), value: doSomething)
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
            
            Button("Do something") {
                doSomething.toggle()
            }
        }
    }
}

#Preview {
    CardInHandArea(cardsDragged: .constant([]), cardsInHand: .constant([CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond"), CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")]))
        .environmentObject(FirebaseHelper())
}
