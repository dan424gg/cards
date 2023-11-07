//
//  DisabledCardView.swift
//  Cards
//
//  Created by Daniel Wells on 11/1/23.
//

import SwiftUI

struct DisabledCardView: View {
    var cardItem: CardItem
    
    var body: some View {
        ZStack {
            Text(cardItem.value)
                .font(.largeTitle)
                .foregroundStyle(.gray)
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
                .frame(width: 50, height: 100)
                .overlay(
                    DiagonalLines()
                        .stroke(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                )
        }
    }
}

#Preview {
    DisabledCardView(cardItem: CardItem(id:0, value: "K", suit: "D"))
}
