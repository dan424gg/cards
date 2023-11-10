//
//  Card.swift
//  Cards
//
//  Created by Daniel Wells on 10/24/23.
//

import SwiftUI

struct CardView: View {
    var cardItem: CardItem
    @Binding var isDisabled: Bool
    
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
//                    Circle()
//                        .fill(Color.black)
//                        .frame(width: 5, height:5))
                    VStack (spacing: 30) {
                        VStack (alignment: .center, spacing: 0) {
                            Text(cardItem.value)
                                .font(.caption2)
                            Image(systemName: "suit.\(cardItem.suit)")
                                .imageScale(.small)
                                .foregroundStyle(cardItem.suit == "spade" || cardItem.suit == "club" ? Color.black : Color.red)
                        }
                        .position(CGPoint(x: 10, y: 20))
                        Text(cardItem.value)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .position(x: 25, y: -10)
                    })
                .opacity(isDisabled ? 0.5 : 1.0)
                .overlay(isDisabled ? DiagonalLines().stroke(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 10)) : nil
                )
        }
        .offset(y: -50)
        .draggable(cardItem)
    }
}

#Preview {
    CardView(cardItem: CardItem(id:0, value: "K", suit: "spade"), isDisabled: .constant(true))
}
