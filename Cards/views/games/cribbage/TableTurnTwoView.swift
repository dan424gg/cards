//
//  OtherPlayerTurnTwoView.swift
//  Cards
//
//  Created by Daniel Wells on 6/9/24.
//

import SwiftUI

struct TableTurnTwoView: View {
    @Environment(\.namespace) var namespace
    @EnvironmentObject var gameHelper: GameHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var showAllCards: Bool = false
    @State var timer: Timer?
    @State var color: Color = .purple
    @State var displayTimedTextContainer: Bool = true
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
    var otherPlayer: Bool = false
    var otherPlayerPointCallOut: [String] = []
    var otherPlayerTeamNumber: Int = -1
    var player: PlayerState

    var body: some View {
        ZStack {
            if player.player_num == (gameHelper.gameState?.player_turn ?? gameObservable.game.player_turn) {
                RoundedRectangle(cornerRadius: 3.5)
                    .fill(specs.theme.colorWay.background)
                    .shadow(color: specs.theme.colorWay.secondary, radius:  15)
                    .shadow(color: specs.theme.colorWay.secondary, radius:  15)
                    .frame(width: 60 * Double(specs.maxY / 852), height: 100 * Double(specs.maxY / 852))
            }
            
            HStack {
                if (showAllCards) {
                    horizontalViewOfCards
                } else {
                    stackedViewOfCards
                        .frame(width: 60 * Double(specs.maxY / 852), height: 100 * Double(specs.maxY / 852))
                }
            }
            .transition(.offset())
            
            
        }
        .frame(width: 60 * Double(specs.maxY / 852), height: 100 * Double(specs.maxY / 852))
        .overlay {
            TimedTextContainer(display: $displayTimedTextContainer, textArray: .constant(player.callouts), visibilityFor: 2.5, color: color)
                .onAppear {
                    if let team = gameHelper.teams.first(where: { $0.team_num == otherPlayerTeamNumber }) {
                        color = Color("\(team.color)")
                    }
                }
        }
    }
    
    var horizontalViewOfCards: some View {
        Group {
            if player.cards_dragged.count > 3 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(Array(player.cards_dragged.reversed().enumerated()), id: \.offset) { (index, cardId) in
                            CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), scale: Double(specs.maxY / 852))
//                                .matchedGeometryEffect(id: cardId, in: namespace)
                                .zIndex(Double(-index))
                                .onTapGesture {
                                    handleOtherPlayerCardTapGesture()
                                }
                            
                        }
                    }
                    .padding()
                }
                .frame(width: 160, height: 100)
            } else {
                HStack(spacing: 5) {
                    ForEach(Array(player.cards_dragged.reversed().enumerated()), id: \.offset) { (index, cardId) in
                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), scale: Double(specs.maxY / 852))
//                            .matchedGeometryEffect(id: cardId, in: namespace)
                            .zIndex(Double(-index))
                            .onTapGesture {
                                handleOtherPlayerCardTapGesture()
                            }
                        
                    }
                }
            }
        }
    }

    var stackedViewOfCards: some View {
        ZStack {
            ForEach(Array(player.cards_dragged.reversed().enumerated()), id: \.offset) { (index, cardId) in
                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), scale: Double(specs.maxY / 852))
//                    .matchedGeometryEffect(id: cardId, in: namespace)
                    .zIndex(Double(-index))
                    .onTapGesture {
                        handleOtherPlayerCardTapGesture()
                    }
            }
        }
        
    }
    
    private func handleOtherPlayerCardTapGesture() {
        if showAllCards {
            timer?.invalidate()
            timer = nil
            withAnimation(.smooth(duration: 0.5)) {
                showAllCards = false
            }
        } else {
            withAnimation(.smooth(duration: 0.5)) {
                showAllCards = true
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false, block: { _ in
                withAnimation(.smooth(duration: 0.5)) {
                    showAllCards = false
                }
            })
        }
    }
}

#Preview {
    TableTurnTwoView(player: .player_one)
}
