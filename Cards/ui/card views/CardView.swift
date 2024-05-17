//
//  Card.swift
//  Cards
//
//  Created by Daniel Wells on 10/24/23.
//

import SwiftUI

struct CardView: View {
    @Environment(GameHelper.self) private var gameHelper
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
                        .stroke(.black.opacity(0.7), lineWidth: 0.5 * scale)
                    
                    Image(systemName: "seal.fill")
                        .resizable()
                        .frame(width: 20 * scale, height: 25 * scale)
                        .foregroundColor(.blue.opacity(0.7))
                    
                    Image(systemName: "seal")
                        .resizable()
                        .frame(width: 20 * scale, height: 25 * scale)
                        .foregroundColor(.black)
                    
                    Image(systemName: "seal")
                        .resizable()
                        .frame(width: 38.46 * scale, height: 45 * scale)
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
                        .stroke(Color.black, lineWidth: 0.5 * scale)
                    
                    ZStack {
                        CText(cardItem.card.value, size: Int(18 * scale))
                            .foregroundStyle(cardItem.card.suit == "spade" || cardItem.card.suit == "club" ? Color.black.opacity(0.8) : Color.red.opacity(0.8))
                            .position(x: cardItem.card.value == "10" ? 11 * scale : 9 * scale, y: 11 * scale)
                        Image(systemName: "suit.\(cardItem.card.suit).fill")
                            .font(.system(size: 11 * scale))
                            .position(x: 9 * scale, y: 26 * scale)
                        
                        CText(cardItem.card.value, size: Int(18 * scale))
                            .foregroundStyle(cardItem.card.suit == "spade" || cardItem.card.suit == "club" ? Color.black.opacity(0.8) : Color.red.opacity(0.8))
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
                .rotation3DEffect(
                    .degrees(backDegree), axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            }
            .disabled(backside || cardIsDisabled)
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
            .onChange(of: [gameHelper.gameState?.play_cards, gameHelper.playerState?.cards_in_hand], initial: true, {
                guard gameHelper.gameState != nil, gameHelper.playerState != nil, gameHelper.gameState!.turn == 2 else {
                    return
                }
                
                if (gameHelper.gameState!.starter_card != cardItem.id && !gameHelper.playerState!.cards_in_hand.contains(cardItem.id) && !gameHelper.gameState!.play_cards.contains(cardItem.id)) {
                    notUsable = true
                }
            })
            .offset(y: positionOffset)
            .rotationEffect(.degrees(rotationOffset))
        }
        .disableAnimations()
    }
}

#Preview {
    return GeometryReader { geo in
        CardView(cardItem: CardItem(id: 9), cardIsDisabled: .constant(false), backside: .constant(true), scale: 2.0)
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background {
                DeviceSpecs().theme.colorWay.background
            }
    }
    .ignoresSafeArea()
}
