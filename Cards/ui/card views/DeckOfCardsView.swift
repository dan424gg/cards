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
    @Binding var cards: [Int]
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    
    var tempTeam = TeamState(team_num: 1, points: 50)
    
    var body: some View {
        ZStack {
            switch(gameObservable.game.game_name) {
                case "cribbage":
                    // displaying the deck
                    ZStack {
                        if firebaseHelper.gameState == nil {
                            ForEach(Array(gameObservable.game.cards.enumerated()), id: \.offset) { (index, cardId) in
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(true), naturalOffset: true)
                                    .matchedGeometryEffect(id: cardId, in: namespace)
                                    .offset(x: -0.1 * Double(index), y: -0.1 * Double(index))
                            }
                        } else {
                            ForEach(Array(cards.enumerated()), id: \.offset) { (index, cardId) in
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(true), naturalOffset: true)
                                    .matchedGeometryEffect(id: cardId, in: namespace)
                                    .offset(x: -0.1 * Double(index), y: -0.1 * Double(index))
                            }
                        }
                    }
                default:
                    Text("shouldn't get here")
            }
        }
    }
}

#Preview {
    return GeometryReader { geo in
        DeckOfCardsView(cards: .constant(Array(0...51)))
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
