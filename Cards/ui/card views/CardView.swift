//
//  Card.swift
//  Cards
//
//  Created by Daniel Wells on 10/24/23.
//

import SwiftUI


struct CardView: View {
    var cardItem: CardItem
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: 50, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
            
            VStack {
                Text(cardItem.card)
                    .font(.largeTitle)
            }
        }
        .draggable(cardItem)
    }
}

#Preview {
    CardView(cardItem: CardItem(id:0, card: "JK"))
}
