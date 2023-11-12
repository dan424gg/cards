//
//  GameView.swift
//  Cards
//
//  Created by Daniel Wells on 11/7/23.
//

import SwiftUI

struct GameView: View {
    var gameName: String = "cribbage"
    
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var cardsDragged: [CardItem] = []
    @State var cardsInHand: [CardItem] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    Text("\(gameName.capitalized)")
                        .font(.largeTitle)
                        .padding()
                    Divider()
                        .frame(width: 300)
                    Spacer()
                }
                
                CircleShape()
                    .stroke(Color.gray.opacity(0.5))
                    .aspectRatio(1.35, contentMode: .fit)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 1.5 )
                
                CribbageBoard()
                    .scaleEffect(x:0.25, y: 0.25)
                    .offset(y: -150)
                VStack {
                    switch (gameName) {
                    case "cribbage":
                        Cribbage(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand).offset(y: 195)
                            .onAppear(perform: {
                                cardsDragged = []
                                if firebaseHelper.playerInfo != nil && firebaseHelper.playerInfo!.cards_in_hand != [] {
                                    cardsInHand = firebaseHelper.playerInfo!.cards_in_hand
                                } else {
                                    cardsInHand = [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")]
                                }
                            })
                    default: EmptyView()
                    }
                }
                .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 2)
                
                CardInHandArea(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand).offset(y: 195)
                    .onAppear(perform: {
                        cardsDragged = []
                        if firebaseHelper.playerInfo != nil && firebaseHelper.playerInfo!.cards_in_hand != [] {
                            cardsInHand = firebaseHelper.playerInfo!.cards_in_hand
                        } else {
                            cardsInHand = [CardItem(id: 39, value: "A", suit: "club"), CardItem(id: 40, value: "2", suit: "club"), CardItem(id: 26, value: "A", suit: "diamond"), CardItem(id: 27, value: "2", suit: "diamond")]
                        }
                    })
                    .offset(y: -10)
                    .scaleEffect(x: 2, y: 2)
            }
        }
    }
}

struct CircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r = rect.height / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: r,
                        startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: false)
        return path
    }
}

#Preview {
    GameView()
        .environmentObject(FirebaseHelper())
}
