//
//  NamesAroundTable.swift
//  Cards
//
//  Created by Daniel Wells on 11/13/23.
//

import SwiftUI

struct NamesAroundTable: View {
    var body: some View {
//        GeometryReader { geo in
            ZStack {
//                Table()
//                    .stroke(Color.gray.opacity(0.5))
//                    .aspectRatio(1.40, contentMode: .fit)

                VStack(spacing: 0) {
                    Text("Katie")
                        .underline(true, color: .red)
                    CardView(cardItem: CardItem(id: 39, value: "A", suit: "club"))
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: 0.55, y: 0.55)
                        .offset(y: -12.5)
                }
                .offset(y: -135)
                
                VStack(spacing: 0) {
                    Text("Ryan")
                        .underline(true, color: .green)
                    CardView(cardItem: CardItem(id: 39, value: "A", suit: "club"))
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: 0.45, y: 0.45)
                        .offset(y: -12.5)
                }
                .offset(y: -135)
                .rotationEffect(.degrees(270))
                
                VStack(spacing: 0) {
                    Text("Ben")
                        .underline(true, color: .blue)
                    CardView(cardItem: CardItem(id: 39, value: "A", suit: "club"))
                        .rotationEffect(.degrees(180))
                        .scaleEffect(x: 0.45, y: 0.45)
                        .offset(y: -12.5)
                }
                .offset(y: -135)
                .rotationEffect(.degrees(90))
            }
        }
//    }
}

#Preview {
    NamesAroundTable()
}
