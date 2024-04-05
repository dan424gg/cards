//
//  CardsView.swift
//  Cards
//
//  Created by Daniel Wells on 3/23/24.
//

import SwiftUI
import Combine

struct CardsView: View {
    @Environment(\.namespace) var namespace
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State var multiplier = 0
    @State var startingRotation = 0
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
    @State var cards: [Int] = []
    @State var cardsInHand: [Int] = []
    @State var cardsDragged: [Int] = []
    
    @State var disableCardsDragged: Bool = false
    
    @State var dontShowCrib: Bool = true
    @State var dontShowStarter: Bool = true
    
    var body: some View {
        ZStack {
            switch (firebaseHelper.gameState?.game_name ?? "cribbage") {
                case "cribbage":
                    cribbage_userDraggedCards
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.7)
                    
                    cribbage_otherPlayersCards
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                        .zIndex(1.0)
                    
                    cribbage_commonCardArea
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.55)
                default:
                    EmptyView()
            }
            
            CardInHandArea(cards: $cards, cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                .position(x: specs.maxX / 2, y: specs.maxY * 1.05)
                .zIndex(1.0)
        }
        .onChange(of: firebaseHelper.playerState?.cards_in_hand, {
            guard firebaseHelper.playerState != nil else {
                return
            }
            
            cardsInHand = firebaseHelper.playerState!.cards_in_hand
        })
        #if DEBUG
        .onChange(of: gameObservable.game.turn, { (old, new) in
            if new == 0 {
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
        .onChange(of: firebaseHelper.gameState?.turn, { (_, new) in
            guard new != nil else {
                return
            }
            
            if new! == 0 {
                cardsDragged = []
                cards = Array(0...51)

                withAnimation {
                    dontShowCrib = true
                    dontShowStarter = true
                }
            }
            
            if dontShowStarter && new! > 1 {
                withAnimation {
                    dontShowStarter = false
                }
            }
            
            if new! == 4 {
                withAnimation {
                    dontShowCrib = false
                }
            }
            
            disableCardsDragged = false
        })
    }
    
    var cribbage_otherPlayersCards: some View {
        ZStack {
            switch (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
                case 0, 1:
                    if firebaseHelper.players == [] {
                        ForEach(Array([PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six].enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: .constant(player.cards_in_hand), showBackside: true)
                                .scaleEffect(0.3)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.18)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation()
                        }
                    } else {
                        ForEach(Array($firebaseHelper.players.enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: player.cards_in_hand, showBackside: true)
                                .scaleEffect(0.2)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.18)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation()
                        }
                    }
                case 2:
                    if firebaseHelper.players == [] {
                        ForEach(Array([PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six].enumerated()), id: \.offset) { (index, player) in
                            TurnTwoView(cardsDragged: .constant(player.cards_dragged), cardsInHand: .constant([]), otherPlayer: true)
                                .scaleEffect(0.4)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.17)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation()
                        }
                    } else {
                        ForEach(Array($firebaseHelper.players.enumerated()), id: \.offset) { (index, player) in
                            TurnTwoView(cardsDragged: player.cards_dragged, cardsInHand: .constant([]), otherPlayer: true)
                                .scaleEffect(0.4)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.17)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation()
                        }
                    }
                case 3, 4:
                    if firebaseHelper.players == [] {
                        ForEach(Array([PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six].enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: .constant(player.cards_in_hand), showBackside: false)
                                .scaleEffect(0.3)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.18)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation()
                        }
                    } else {
                        ForEach(Array($firebaseHelper.players.enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: player.cards_in_hand, showBackside: false)
                                .scaleEffect(0.3)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.18)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation()
                        }
                    }
                default:
                    Text("should not get here")
            }
        }
        .frame(width: specs.maxX * 0.4, height: specs.maxY * 0.4)
    }
    
    var cribbage_userDraggedCards: some View {
        VStack {
            switch (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
                case 1:
                    VStack {
                        Text("Pick \(firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") for the crib!")
                            .font(.custom("LuckiestGuy-Regular", size: 16))
                            .offset(y: 1.6)
                        Spacer()
                        HStack(spacing: 20) {
                            ForEach(cardsDragged, id: \.self) { card in
                                CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(true), backside: .constant(false))
                                    .matchedGeometryEffect(id: card, in: namespace, properties: .position)
                                    .transition(.offset())
                                    .onTapGesture {
                                        withAnimation {
                                            cardsDragged.removeAll(where: { $0 == card })
                                            cardsInHand.append(card)
                                        }
                                    }
                            }
                        }
                        
                        Button {
                            guard firebaseHelper.gameState != nil else {
                                return
                            }
                            
                            Task {
                                disableCardsDragged = true
                                await firebaseHelper.updateGame(["crib": cardsDragged], arrayAction: .append)
                                await firebaseHelper.updatePlayer(["cards_in_hand": cardsDragged], arrayAction: .remove)
                                await firebaseHelper.updatePlayer(["is_ready": true], arrayAction: .replace)
                            }
                        } label: {
                            Text("Submit")
                                .foregroundStyle(determineSubmitColor())
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .offset(y: 1.6)
                        }
                    }
                    .disabled(disableCardsDragged)
                case 2:
                    VStack {
                        if firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn == firebaseHelper.playerState?.player_num ?? 0 {
                            Text("Play a card!")
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .offset(y: 1.6)
                        } else {
                            Text("Waiting...")
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .offset(y: 1.6)
                        }
                        Spacer()
                        TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                            .onAppear {
                                cardsDragged = []

                                guard firebaseHelper.playerState != nil, firebaseHelper.playerState!.is_lead else {
                                    return
                                }
                                
                                // reinitialize fields used during play (turn 2)
                                Task {
                                    await firebaseHelper.updateGame([
                                        "running_sum": 0,
                                        "play_cards": [Int](),
                                        "num_cards_in_play": 0,
                                        "num_go": 0
                                    ], arrayAction: .replace)
                                }
                            }
                            .onDisappear {
                                cardsInHand = cardsDragged
                            }
                    }
                    .offset(y: -10)
                case 3:
                    ZStack {
                        VStack {
                            Text("Time to score hands!")
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .offset(y: 1.6)
                            Spacer()
                        }
                    }
                case 4:
                    ZStack {
                        VStack {
                            Text("and the crib!")
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .offset(y: 1.6)
                            Spacer()
                        }
                    }
                default: EmptyView()
            }
        }
        .frame(width: 250, height: 150)
    }
    
    var cribbage_commonCardArea: some View {
        HStack(spacing: -20) {
            ZStack {
                HStack(spacing: -33) {
                    if firebaseHelper.gameState?.turn ?? gameObservable.game.turn > 1 {
                        ForEach(Array(firebaseHelper.gameState?.crib.enumerated() ?? gameObservable.game.crib.enumerated()), id: \.offset) { (index, cardId) in
                            CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: $dontShowCrib)
                                .matchedGeometryEffect(id: cardId, in: namespace)
                        }
                    }
                }
                .zIndex(0.0)
                
                if firebaseHelper.gameState?.turn ?? gameObservable.game.turn == 4 {
                    PointContainer(crib: true)
                        .zIndex(1.0)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                                Task {
                                    await firebaseHelper.updatePlayer(["is_ready": true])
                                }
                            })
                        }
                }
            }
            .frame(width: 185, height: 100)
            .scaleEffect(0.66)

            ZStack {
                CardView(cardItem: CardItem(id: firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card), cardIsDisabled: .constant(true), backside: $dontShowStarter, naturalOffset: true)
                    .offset(x: -0.1 * Double(cards.endIndex), y: -0.1 * Double(cards.endIndex))
                    .scaleEffect(0.66)
                    .zIndex(1.0)
                
                DeckOfCardsView(cards: $cards)
                    .scaleEffect(0.66)
                    .zIndex(0.0)
            }
        }
    }
    
    func determineSubmitColor() -> Color {
        switch (firebaseHelper.gameState?.game_name ?? gameObservable.game.game_name) {
            case "cribbage":
                switch (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
                    case 1:
                        if firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 {
                            if cardsDragged.count < 2 {
                                return .red
                            } else {
                                return .green
                            }
                        } else {
                            if cardsDragged.count < 1 {
                                return .red
                            } else {
                                return .green
                            }
                        }
                    case 2:
                        if cardsDragged.count - (firebaseHelper.playerState?.cards_dragged.count ?? 0) < 1 {
                            return .red
                        } else {
                            return .green
                        }
                    default: return .black
                }
                
            default: return .black
        }
    }
    
    func setMultiplierAndRotation() {
        if let gameState = firebaseHelper.gameState {
            switch gameState.num_teams {
                case 2:
                    if gameState.num_players == 2 {
                        startingRotation = 0
                        multiplier = 0
                    } else {
                        startingRotation = 270
                        multiplier = 90
                    }
                case 3:
                    if gameState.num_players == 3 {
                        startingRotation = 300
                        multiplier = 120
                    } else {
                        startingRotation = 240
                        multiplier = 60
                    }
                default:
                    startingRotation = 0
                    multiplier = 0
            }
        } else {
            startingRotation = 240
            multiplier = 60
        }
    }
}

#Preview {
    return GeometryReader { geo in
        CardsView()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
//            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(Color("OffWhite").opacity(0.1))
        
    }
    .ignoresSafeArea()
}
