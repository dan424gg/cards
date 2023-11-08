//
//  CardDropArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI

struct TurnOneView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    @State private var firstDropAreaBorderColor: Color = .clear
    @State private var firstDropAreaBorderWidth: CGFloat = 1.0
    @State private var secondDropAreaBorderColor: Color = .clear
    @State private var secondDropAreaBorderWidth: CGFloat = 1.0
    
    var body: some View {
        Text("The Deal")
            .font(.title2)
        HStack(spacing: 10) {
            if cardsDragged.count > 0 {
                CardView(cardItem: cardsDragged[0])
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
            
            if cardsDragged.count > 1 {
                CardView(cardItem: cardsDragged[1])
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

#Preview {
    TurnOneView(cardsDragged: .constant([CardItem(id: 0, value: "A", suit: "H")]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
