//
//  CardInHandArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI


struct CardInHandArea: View {
    @Environment(\.namespace) var namespace
    @Environment(GameHelper.self) private var gameHelper
    @Binding var cards: [Int]
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
        
    var showBackside = false

    var body: some View {
        ZStack {
            ForEach(Array(cardsInHand.enumerated()), id: \.offset) { (index, cardId) in
                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: .constant(showBackside), scale: 2.0)
                    .offset(y: -100)
                    .rotationEffect(.degrees(-Double((cardsInHand.count - 1) * 6) + Double(index * 12)))
                    .onTapGesture {
                        determineTapGesture(cardId: cardId)
                    }
            }
        }
        .animation(.smooth, value: cardsInHand)
        .transition(.opacity)
    }
    
    func determineTapGesture(cardId: Int) {
        switch (gameHelper.gameState?.game_name ?? gameObservable.game.game_name) {
            case "cribbage":
                switch (gameHelper.gameState?.turn ?? gameObservable.game.turn) {
                    case 1:
                        if gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 {
                            if cardsDragged.count < 2 {
                                withAnimation {
                                    cardsInHand.removeAll(where: { $0 == cardId })
                                    cardsDragged.append(cardId)
                                }
                            }
                        } else {
                            if cardsDragged.count < 1 {
                                withAnimation {
                                    cardsInHand.removeAll(where: { $0 == cardId })
                                    cardsDragged.append(cardId)
                                }
                            }
                        }
                    case 2:
                        if gameHelper.gameState?.player_turn ?? gameObservable.game.player_turn == gameHelper.playerState?.player_num ?? 0
                            && (cardsDragged.count - (gameHelper.playerState?.cards_dragged.count ?? 0) != 1) {
                            withAnimation {
                                cardsInHand.removeAll(where: { $0 == cardId })
                                cardsDragged.append(cardId)
                            }
                        }
                    default: print("no turn")
                }
            default: print("no game")
        }
    }
}

#Preview {
    GeometryReader { geo in
        CardInHandArea(cards: .constant(Array(5...51)), cardsDragged: .constant([]), cardsInHand: .constant(Array([10, 13, 4, 31])))
            .environment(GameHelper())
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
    }
    .background {
        DeviceSpecs().theme.colorWay.background
    }
}
