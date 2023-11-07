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
                .overlay(
                    VStack (spacing: 30) {
                        Text(cardItem.suit)
                            .font(.footnote)
                            .position(CGPoint(x: 10, y: 10))
                        Text(cardItem.value)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .position(x: 25, y: -10)
                    })
            
        }
        .draggable(cardItem)
    }
}

#Preview {
    CardView(cardItem: CardItem(id:0, value: "K", suit: "S"))
}
