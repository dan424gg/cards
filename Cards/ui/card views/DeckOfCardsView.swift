//
//  DeckOfCardsView.swift
//  Cards
//
//  Created by Daniel Wells on 11/15/23.
//

import SwiftUI

struct DeckOfCardsView: View {
    @Environment(\.namespace) var namespace
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
//    @Binding var cards: [Int]
    @State var dontShowCrib: Bool = true
    @State var dontShowStarter: Bool = true
    @StateObject private var gameObservable = GameObservable(game: GameState.game)

    var tempTeam = TeamState(team_num: 1, points: 50)
        
    var body: some View {
        ZStack {
//            Text("\(gameObservable.game.turn)")
//                .font(.largeTitle)
//                .offset(y: -200)
            
                switch(gameObservable.game.game_name) {
                    case "cribbage":
                        HStack(spacing: 5) {
                            // displaying the crib
                            HStack(spacing: -33) {
                                if firebaseHelper.gameState?.turn ?? gameObservable.game.turn > 1 {
                                    ForEach(Array(firebaseHelper.gameState?.crib.enumerated() ?? gameObservable.game.crib.enumerated()), id: \.offset) { (index, cardId) in
                                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: $dontShowCrib, naturalOffset: true)
                                            .matchedGeometryEffect(id: cardId, in: namespace)
                                    }
                                }
                            }
                            .frame(width: 185, height: 100)

                            // displaying the deck
                            ZStack {
                                if firebaseHelper.gameState == nil {
                                    ForEach(Array(gameObservable.game.cards.enumerated()), id: \.offset) { (index, cardId) in
                                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(true), naturalOffset: true)
                                            .matchedGeometryEffect(id: cardId, in: namespace)
                                            .offset(x: -0.1 * Double(index), y: -0.1 * Double(index))
                                    }

                                    CardView(cardItem: CardItem(id: gameObservable.game.starter_card), cardIsDisabled: .constant(true), backside: $dontShowStarter, naturalOffset: true)
                                        .offset(x: -0.1 * Double(gameObservable.game.cards.endIndex), y: -0.1 * Double(gameObservable.game.cards.endIndex))
                                } else {
                                    ForEach(Array(firebaseHelper.gameState!.cards.enumerated()), id: \.offset) { (index, cardId) in
                                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(true), naturalOffset: true)
                                            .matchedGeometryEffect(id: cardId, in: namespace)
                                            .offset(x: -0.1 * Double(index), y: -0.1 * Double(index))
                                    }

                                    CardView(cardItem: CardItem(id: firebaseHelper.gameState!.starter_card), cardIsDisabled: .constant(true), backside: $dontShowStarter, naturalOffset: true)
                                        .offset(x: -0.1 * Double(firebaseHelper.gameState!.cards.endIndex), y: -0.1 * Double(firebaseHelper.gameState!.cards.endIndex))
                                }
                            }
                            .onChange(of: firebaseHelper.gameState, { (old, new) in
                                guard firebaseHelper.gameState != nil, old != nil, new != nil else {
                                    return
                                }
                                
                                let turn = new!.turn
                                
                                if turn == 1 {
                                    withAnimation {
                                        dontShowCrib = true
                                        dontShowStarter = true
                                    }
                                }
                                
                                if dontShowStarter && turn > 1 {
                                    withAnimation {
                                        dontShowStarter = false
                                    }
                                }
                                
                                if turn == 4 {
                                    withAnimation {
                                        dontShowCrib = false
                                    }
                                }
                            })
                            #if DEBUG
                            .onChange(of: gameObservable.game.turn, { (old, new) in
                                if new == 1 {
                                    withAnimation {
                                        dontShowCrib = true
                                        dontShowStarter = true
                                    }
                                }
                                
                                if dontShowStarter && new > 1 {
                                    withAnimation {
                                        dontShowStarter = false
                                    }
                                }
                                
                                if new == 4 {
                                    withAnimation {
                                        dontShowCrib = false
                                    }
                                }
                            })
                            #endif
                        }
                    default: EmptyView()
                }
//            }
//        }
//             used for preview testing
//            Button("increment") {
//                withAnimation {
//                    gameObservable.game.turn = (gameObservable.game.turn % 4) + 1
//                }
//            }
//            .offset(y: 150)
        }
        .scaleEffect(0.66)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    return GeometryReader { geo in
        DeckOfCardsView()
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
