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
            }
            
            HStack(spacing: 30, content: {
                Button("add") {
                    firebase.playerState!.cards_in_hand.append(Int.random(in: 5...14))
                }
                
                CardInHandArea(cardsDragged: .constant([]), cardsInHand: $cardsInHand)
                    .frame(width: 100, height: 100)
                
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
                        firebase.playerState!.cards_in_hand = Array(0...4)
                    }
                }
            }
            .offset(y: -100)
        }
        .onChange(of: firebase.playerState?.cards_in_hand, initial: true, { (old, new) in
            guard firebase.playerState != nil, old != nil, new != nil else {
                firebase.playerState = PlayerState()
                return
            }
            
            // check if a card was removed, run animation
            if old!.count > new!.count {
                let diff = old!.filter { !new!.contains($0) }
                var temp = diff
                
                for i in 0..<diff.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(i)), execute: {
                        withAnimation {
                            cardsInHand.removeAll(where: {
                                $0 == temp.first
                            })
                            cards.append(temp.removeFirst())
                        }
                    })
                }
            } else {
                var diff = new!.filter { !old!.contains($0) }
                print(diff)
                print(cards)
                
                for i in 0..<diff.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (0.5 * Double(i)), execute: {
                        if let idx = cards.first(where: {
                            $0 == diff.removeFirst()
                        }) {
                            withAnimation {
                                print(idx)
                                cardsInHand.append(cards.remove(at: idx))
                            }
                        }
                    })
                }
            }
        })
    }
}

struct TestView: View {
    @EnvironmentObject var firebase: FirebaseHelper
    @State var temp: [Int] = []
    
    var body: some View {
        CardInHandArea(cardsDragged: .constant([]), cardsInHand: $temp)
            .border(.red)
            .offset(y: 200)
            .onChange(of: firebase.playerState?.cards_in_hand, initial: true, { (old, new) in
                guard new != nil, old != nil else {
                    return
                }
                
                withAnimation {
                    temp = new!
                }
            })
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
