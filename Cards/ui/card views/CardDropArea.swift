//
//  CardDropArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI

struct CardDropArea: View {
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    @State private var dropAreaBorderColor: Color = .black
    @State private var dropAreaBorderWidth: CGFloat = 1.0
    var body: some View {
        HStack(spacing: 10) {
            ForEach(cardsDragged, id: \.id) { card in
                CardView(cardItem: card)
            }
        }
        .frame(width: 300, height: 200)
        .background(Color.brown.opacity(0.25))
        .border(dropAreaBorderColor, width: dropAreaBorderWidth)
        .dropDestination(for: CardItem.self) { items, location in
            if !cardsDragged.contains(items.first!) {
                cardsDragged.append(items.first!)
                cardsInHand.removeAll(where: { card in
                    card == items.first!
                })
            }
            return true
        } isTargeted: { inDropArea in
            dropAreaBorderColor = inDropArea ? .green : .black
            dropAreaBorderWidth = inDropArea ? 7.0 : 1.0
        }
        
        Button("Submit") {
            //
        }
        .buttonStyle(.bordered)
        
    }
}

#Preview {
    CardDropArea(cardsDragged: .constant([CardItem(id: 0, card: "HA"), CardItem(id: 1, card: "JK")]), cardsInHand: .constant([CardItem(id: 0, card: "DJ"), CardItem(id: 1, card: "D5"), CardItem(id: 2, card: "SA")]))
}
