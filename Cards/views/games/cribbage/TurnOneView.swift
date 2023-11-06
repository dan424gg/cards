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
    
    @State private var dropAreaBorderColor: Color = .clear
    @State private var dropAreaBorderWidth: CGFloat = 1.0
    
    var body: some View {
        
        HStack(spacing: 10) {
            if cardsDragged.count > 0 {
                CardView(cardItem: cardsDragged[0])
            } else {
                CardPlaceHolder()
                    .border(dropAreaBorderColor, width: dropAreaBorderWidth)
            }
            
            if cardsDragged.count > 1 {
                CardView(cardItem: cardsDragged[1])
            } else {
                CardPlaceHolder()
                    .border(dropAreaBorderColor, width: dropAreaBorderWidth)
            }
        }
        .dropDestination(for: CardItem.self) { items, location in
            if !cardsDragged.contains(items.first!) {
                cardsDragged.append(items.first!)
                cardsInHand.removeAll(where: { card in
                    card == items.first!
                })
            }
            return true
        } isTargeted: { inDropArea in
            dropAreaBorderColor = inDropArea ? .green : .clear
            dropAreaBorderWidth = inDropArea ? 7.0 : 1.0
        }
    }
}

#Preview {
    TurnOneView(cardsDragged: .constant([CardItem(id: 0, card: "HA")]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
