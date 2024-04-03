//
//  CardInHandArea.swift
//  Cards
//
//  Created by Daniel Wells on 10/28/23.
//

import SwiftUI


struct CardInHandArea: View {
    @Environment(\.namespace) var namespace
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cards: [Int]
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    
    @State var shownCardsInHand: [Int] = []
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
        
    var showBackside = false

    var body: some View {
        ZStack {
            ForEach(Array(shownCardsInHand.enumerated()), id: \.offset) { (index, cardId) in
                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: .constant(showBackside))
                    .matchedGeometryEffect(id: cardId, in: namespace)
                    .offset(y: -50)
                    .scaleEffect(x: 2, y: 2)
                    .rotationEffect(.degrees(-Double((shownCardsInHand.count - 1) * 6) + Double(index * 12)))
                    .onTapGesture {
                        determineTapGesture(cardId: cardId)
                    }
            }
        }
        .onAppear {
            shownCardsInHand = cardsInHand
        }
        .onChange(of: cardsInHand, { (old, new) in
            if new.count >= old.count {
                let newCards = new.filter { !old.contains($0) }
                for indivCard in newCards {
                    withAnimation {
                        cards.removeAll(where: { $0 == indivCard })
                        shownCardsInHand.append(indivCard)
                    }
                }
            } else {
                let removedCards = old.filter { !new.contains($0) }
                for indivCard in removedCards {
                    withAnimation {
                        shownCardsInHand.removeAll(where: { $0 == indivCard })
                    }
                }
            }
        })
    }
    
    func determineTapGesture(cardId: Int) {
        switch (firebaseHelper.gameState?.game_name ?? gameObservable.game.game_name) {
            case "cribbage":
                switch (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
                    case 1:
                        if firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 {
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
                        if firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn == firebaseHelper.playerState?.player_num ?? 0
                            && (cardsDragged.count - (firebaseHelper.playerState?.cards_dragged.count ?? 0) != 1) {
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
    
    func dealCards(_ cardsArr: [Int]) {
        guard cardsArr != [] else {
            return
        }
        
        for indivCard in cardsArr {
            withAnimation {
//                cards.removeAll(where: { $0 == indivCard })
                shownCardsInHand.append(indivCard)
            }
        }
    }
    
    func dealCards(_ card: Int) {
        guard card <= 51 || card >= 0 else {
            return
        }
        
        withAnimation {
//            cards.removeAll(where: { $0 == card })
            shownCardsInHand.append(card)
        }
    }
}

#Preview {
    CardInHandArea(cards: .constant(Array(5...51)), cardsDragged: .constant([]), cardsInHand: .constant(Array(0...4)))
        .environmentObject(FirebaseHelper())
}
