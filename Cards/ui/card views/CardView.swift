//
//  Card.swift
//  Cards
//
//  Created by Daniel Wells on 10/24/23.
//

import SwiftUI

struct CardView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    var cardItem: CardItem
    @Binding var cardIsDisabled: Bool
    @State var backside = false
    @State var backDegree = 0.0
    @State var frontDegree = 90.0
    @State var naturalOffset = false
    @State var rotationOffset: Double = 0.0
    @State var positionOffset: Double = 0.0
    @State var notUsable: Bool = false
    
    var cardArrs: [[Int]] {[
        firebaseHelper.gameState?.play_cards ?? [],
        firebaseHelper.playerState?.cards_in_hand ?? []
    ]}
    var width = 50.0
    var height = 100.0

    var body: some View {
        VStack {
            ZStack {
                // backside
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black.opacity(0.7), lineWidth: 1)
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
                        .fill(notUsable ? Color.gray.opacity(0.35) : Color.clear)
                        .stroke(Color.black, lineWidth: 1)
                    VStack (spacing: 30) {
                        VStack (alignment: .center, spacing: 0) {
                            Text(cardItem.card.value)
                                .font(.caption2)
                            Image(systemName: "suit.\(cardItem.card.suit)")
                                .imageScale(.small)
                        }
                        .position(CGPoint(x: 10, y: 20))
                        Text(cardItem.card.value)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .position(x: 25, y: -10)
                    }
                    .foregroundStyle(cardItem.card.suit == "spade" || cardItem.card.suit == "club" ? Color.black.opacity(0.8) : Color.red.opacity(0.8))
                }
                .frame(width: 50, height: 100)
                .draggable(cardItem)
                .disabled(backside || cardIsDisabled)
                .rotation3DEffect(
                    .degrees(backDegree), axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            }
            .onAppear {
                if backside {
                    backDegree = -90.0
                    frontDegree = 0.0
                }
                
                if naturalOffset {
                    var rng = RandomNumberGeneratorWithSeed(seed: cardItem.id * (firebaseHelper.gameState?.group_id ?? 1))
                    // [-5,5)
                    rotationOffset = (Double(Int(rng.next()) % 10000) / 1000.0) - 5.0
                    // [-1,1)
                    positionOffset = (Double(Int(rng.next()) % 10000) / 5000.0) - 1.0
                }
            }
            .onChange(of: [firebaseHelper.gameState?.play_cards, firebaseHelper.playerState?.cards_in_hand], initial: true, {
                guard firebaseHelper.gameState != nil, firebaseHelper.playerState != nil, firebaseHelper.gameState!.turn == 2 else {
                    return
                }
                
                if (firebaseHelper.gameState!.starter_card != cardItem.id && !firebaseHelper.playerState!.cards_in_hand.contains(cardItem.id) && !firebaseHelper.gameState!.play_cards.contains(cardItem.id)) {
                    notUsable = true
                }
            })
            .offset(y: positionOffset)
            .rotationEffect(.degrees(rotationOffset))
        }
    }
}

#Preview {
    CardView(cardItem: CardItem(id: 14), cardIsDisabled: .constant(false))
        .environmentObject(FirebaseHelper())
}
