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
    @Binding var backside: Bool
    @State var backDegree = 0.0
    @State var frontDegree = 90.0
    @State var naturalOffset = false
    @State var rotationOffset: Double = 0.0
    @State var positionOffset: Double = 0.0
    @State var notUsable: Bool = false
    
    var scale: Double = 1.0

    var body: some View {
        VStack {
            ZStack {
                // backside
                ZStack {
                    RoundedRectangle(cornerRadius: 3.5)
                        .fill(.blue.gradient)
                        .stroke(.black.opacity(0.7), lineWidth: 0.5)
                    
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
                .frame(width: Double(60 * scale), height: Double(100 * scale))
                .rotation3DEffect(
                    .degrees(frontDegree), axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                
                // frontside
                ZStack {
                    RoundedRectangle(cornerRadius: 3.5)
                        .fill(Color.white)
                        .fill(notUsable ? Color.gray.opacity(0.35) : Color.clear)
                        .stroke(Color.black, lineWidth: 0.5)
                    
                    ZStack {
                        Text(cardItem.card.value)
                            .font(.custom("LuckiestGuy-Regular", size: Double(18 * scale)))
                            .baselineOffset(-2.2 * Double(scale))
                            .position(x: cardItem.card.value == "10" ? 11 * scale : 9 * scale, y: 11 * scale)
                        Image(systemName: "suit.\(cardItem.card.suit).fill")
                            .font(.system(size: 11 * scale))
                            .position(x: 9 * scale, y: 26 * scale)
                        
                        Text(cardItem.card.value)
                            .font(.custom("LuckiestGuy-Regular", size: 18 * scale))
                            .baselineOffset(-2.2 * scale)
                            .position(x: cardItem.card.value == "10" ? 11 * scale : 9 * scale, y: 11 * scale)
                            .rotationEffect(.degrees(180.0))
                        Image(systemName: "suit.\(cardItem.card.suit).fill")
                            .font(.system(size: 11 * scale))
                            .position(x: 9 * scale, y: 26 * scale)
                            .rotationEffect(.degrees(180.0))
                        
                        Image(systemName: "suit.\(cardItem.card.suit).fill")
                            .font(.system(size: 16 * scale))
                    }
                    .foregroundStyle(cardItem.card.suit == "spade" || cardItem.card.suit == "club" ? Color.black.opacity(0.8) : Color.red.opacity(0.8))
                }
                .frame(width: Double(60 * scale), height: Double(100 * scale))
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
                } else {
                    backDegree = 0.0
                    frontDegree = 90.0
                }
            }
            .onChange(of: backside, initial: true, {
                if backside {
                    withAnimation(.linear(duration: 0.2)) {
                        backDegree = -90.0
                    }
                    
                    withAnimation(.linear(duration: 0.2).delay(0.2)) {
                        frontDegree = 0.0
                    }
                } else {
                    withAnimation(.linear(duration: 0.2).delay(0.2)) {
                        backDegree = 0.0
                    }
                    
                    withAnimation(.linear(duration: 0.2)) {
                        frontDegree = 90.0
                    }
                }
            })
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
    CardView(cardItem: CardItem(id: 51), cardIsDisabled: .constant(false), backside: .constant(false), scale: 2.0)
        .environmentObject(FirebaseHelper())
}
