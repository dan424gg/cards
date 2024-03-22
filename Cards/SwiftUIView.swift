//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @EnvironmentObject var firebase: FirebaseHelper
    @State var cardsInHand: [Int] = []
    @State var cards: [Int] = Array(0...14)
    
    @Environment(\.namespace) var namespace
        
    var body: some View {
        ZStack {
            ForEach(cards, id: \.self) { card in
                CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(true), backside: .constant(true))
                    .matchedGeometryEffect(id: card, in: namespace)
                    .zIndex(0.0)
            }
            
            HStack(spacing: 30, content: {
                Button("add") {
                    firebase.playerState!.cards_in_hand.append(Int.random(in: 5...14))
                }
                
                TestView(temp: $cardsInHand)
                    .zIndex(1.0)
                
                Button("remove") {
                    firebase.playerState!.cards_in_hand.removeFirst()
                }
            })
            .frame(width: 300, height: 200)
            .offset(y: 300)

            Button("press me") {
                withAnimation {
                    if cards.isEmpty {
                        cards = Array(0...14)
                        cardsInHand = []
                    } else {
                        for i in 4...9 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + (1.0 * Double(i)), execute: {
                                withAnimation {
                                    firebase.gameState!.cards.removeAll(where: {
                                        $0 == i
                                    })
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                        withAnimation {   
                                            firebase.playerState!.cards_in_hand.append(i)
                                        }
                                    })
                                }
                            })
                        }
                    }
                }
            }
            .offset(y: -100)
        }
        .onAppear {
            firebase.gameState = GameState()
            firebase.playerState = PlayerState()
        }
    }
}

struct TestView: View {
    @EnvironmentObject var firebase: FirebaseHelper
    @Binding var temp: [Int]
    
    var body: some View {
        TestView2(temp: $temp)
    }
}

struct TestView2: View {
    @EnvironmentObject var firebase: FirebaseHelper
    @Binding var temp: [Int]
    
    var body: some View {
        CardInHandArea(cardsDragged: .constant([]), cardsInHand: .constant([-1]))
            .frame(width: 100, height: 100)
    }
}

#Preview {
    let deviceSpecs = DeviceSpecs()
    
    return GeometryReader { geo in
        SwiftUIView()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .ignoresSafeArea()
}
