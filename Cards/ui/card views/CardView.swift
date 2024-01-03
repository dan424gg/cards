//
//  Card.swift
//  Cards
//
//  Created by Daniel Wells on 10/24/23.
//

import SwiftUI

struct CardView: View {
    var cardItem: CardItem
    @Binding var cardIsDisabled: Bool
    @State var backside = false
    @State var backDegree = 0.0
    @State var frontDegree = 90.0
    
    var width = 50.0
    var height = 100.0

    var body: some View {
        VStack {
            ZStack {
                // backside
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black.opacity(0.7), lineWidth: 3)
                        .frame(width: 50, height: 100)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue.gradient)
                        .frame(width: width, height: height)
                        .shadow(color: .black, radius: 2, x: 0, y: 0)
                    
                    Image(systemName: "seal.fill")
                        .resizable()
                        .frame(width: 20, height: 25)
                        .foregroundColor(.blue.opacity(0.7))
                    
                    Image(systemName: "seal")
                        .resizable()
                        .frame(width: 20, height: 25)
                        .foregroundColor(.black)
                    
                    Image(systemName: "seal")
                        .resizable()
                        .frame(width: 38.46, height: 45)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(width: 50, height: 100)
                .rotation3DEffect(
                    .degrees(frontDegree), axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                
                // frontside
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .stroke(Color.black, lineWidth: 1)
                    VStack (spacing: 30) {
                        VStack (alignment: .center, spacing: 0) {
                            Text(cardItem.getCard().value)
                                .font(.caption2)
                            Image(systemName: "suit.\(cardItem.getCard().suit)")
                                .imageScale(.small)
                        }
                        .position(CGPoint(x: 10, y: 20))
                        Text(cardItem.getCard().value)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .position(x: 25, y: -10)
                    }
                    .foregroundStyle(cardItem.getCard().suit == "spade" || cardItem.getCard().suit == "club" ? Color.black.opacity(0.8) : Color.red.opacity(0.8))
                }
                .frame(width: 50, height: 100)
                .draggable(cardItem)
                .disabled(backside)
                .rotation3DEffect(
                    .degrees(backDegree), axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            }
            .onAppear {
                if backside {
                    backDegree = -90.0
                    frontDegree = 0.0
                }
            }
        }
    }
}

#Preview {
    CardView(cardItem: CardItem(id: 0), cardIsDisabled: .constant(false))
}
