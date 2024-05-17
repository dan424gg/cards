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
    @Environment(GameHelper.self) private var gameHelper
    @Environment(DeviceSpecs.self) private var specs
    @State var multiplier = 0
    @State var startingRotation = 0
    @StateObject var gameObservable: GameObservable/* = GameObservable(game: .game)*/
    @State var cards: [Int] = []
    @State var cardsInHand: [Int] = []
    @State var cardsDragged: [Int] = [53,54]
    
    @State var disableCardsDragged: Bool = false
    
    @State var dontShowCrib: Bool = true
    @State var dontShowStarter: Bool = true
    @State var cribYPosition: CGFloat = -1.0
    @State var cribSpacing: CGFloat = -1.0
    @State var i: Int = -1
    
    var body: some View {
        ZStack {
            switch (gameHelper.gameState?.game_name ?? "cribbage") {
                case "cribbage":
                    cribbage_userDraggedCards
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.7)
                        .offset(y: 50)
                    
                    cribbage_otherPlayersCards
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                        .zIndex(1.0)
                    
                    cribbage_commonCardArea
                        .onAppear {
                            cribSpacing = -33
                            cribYPosition = specs.maxY * 0.47
                        }
                        .onChange(of: gameHelper.gameState?.turn, initial: true, { (_, new) in
                            guard new != nil else {
                                cribSpacing = determineCribSpacing(turn: gameObservable.game.turn)
                                cribYPosition = determineCommonAreaPosition(turn: gameObservable.game.turn)
                                return
                            }
                            
                            withAnimation(.smooth.speed(0.5)) {
                                cribSpacing = determineCribSpacing(turn: new!)
                                cribYPosition = determineCommonAreaPosition(turn: new!)
                            }
                        })
                        .position(x: specs.maxX / 2, y: cribYPosition)
                    
                default:
                    EmptyView()
            }
            
            CardInHandArea(cards: $cards, cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
//                .onAppear {
//                    cardsInHand = [53,54,55,56]
//                }
                .scaleEffect(specs.maxY / 852)
                .position(x: specs.maxX / 2, y: specs.maxY * 1.07)
                .zIndex(1.0)
                .offset(y: 50)
        }
        .onChange(of: gameHelper.gameState?.cards, { (_, new) in
            guard new != nil else {
                return
            }
            
            cards = new!
        })
        .onChange(of: gameHelper.playerState?.cards_in_hand, initial: true, {
            guard gameHelper.playerState != nil else {
                return
            }
            
            cardsInHand = gameHelper.playerState!.cards_in_hand
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
        .onChange(of: gameHelper.gameState?.turn, initial: true, { (_, new) in
            guard new != nil else {
                return
            }
            
            if new! == 0 {
                cardsDragged = []
//                cards = Array(0...51)

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
            switch (gameHelper.gameState?.turn ?? gameObservable.game.turn) {
                case 0, 1:
                    if gameHelper.players == [] {
                        ForEach(Array(GameState.players.enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: .constant(player.cards_in_hand), showBackside: true)
                                .scaleEffect(0.3 * (specs.maxX / 393))
                                .offset(y: specs.maxX * 0.4)
                                .rotationEffect(.degrees(-180.0))
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                                .disabled(true)
                        }
                        .onChange(of: GameState.players, initial: true, {
                            setMultiplierAndRotation(gameObservable.game.num_teams, gameObservable.game.num_players)
                        })
                    } else {
                        ForEach(Array(gameHelper.players.enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: Binding(get: { player.cards_in_hand }, set: { _ in }), showBackside: true)
                                .scaleEffect(0.3 * (specs.maxX / 393))
                                .offset(y: specs.maxX * 0.4)
                                .rotationEffect(.degrees(-180.0))
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                                .disabled(true)
                        }
                        .onAppear {
                            setMultiplierAndRotation(gameHelper.gameState!.num_teams, gameHelper.gameState!.num_players)
                        }
                    }
                case 2:
                    if gameHelper.players == [] {
                        ForEach(Array(GameState.players.enumerated()), id: \.offset) { (index, player) in
                            TurnTwoView(cardsDragged: .constant(player.cards_dragged), cardsInHand: .constant([]), otherPlayer: true, otherPlayerPointCallOut: player.callouts, otherPlayerTeamNumber: player.team_num)
                                .scaleEffect(min(0.7 * (specs.maxX / 393), 0.7))
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxX * 0.32)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onChange(of: GameState.players, initial: true, {
                            setMultiplierAndRotation(gameObservable.game.num_teams, gameObservable.game.num_players)
                        })
                    } else {
                        ForEach(Array(gameHelper.players.enumerated()), id: \.offset) { (index, player) in
                            TurnTwoView(cardsDragged: Binding (get: { player.cards_dragged }, set: { _ in }), cardsInHand: .constant([]), otherPlayer: true, otherPlayerPointCallOut: player.callouts, otherPlayerTeamNumber: player.team_num)
                                .scaleEffect(min(0.7 * (specs.maxX / 393), 0.7))
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxX * 0.32)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation(gameHelper.gameState!.num_teams, gameHelper.gameState!.num_players)
                        }
                    }
                case 3, 4:
                    if gameHelper.players == [] {
                        ForEach(Array([PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six].enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: .constant(player.cards_in_hand), showBackside: false)
                                .scaleEffect(0.3 * (specs.maxX / 393))
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxX * 0.4)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                                .disabled(true)
                        }
                        .onAppear {
                            setMultiplierAndRotation(gameObservable.game.num_teams, gameObservable.game.num_players)
                        }
                    } else {
                        ForEach(Array(gameHelper.players.enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: Binding( get: { player.cards_in_hand }, set: { _ in }), showBackside: false)
                                .scaleEffect(0.3 * (specs.maxX / 393))
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxX * 0.4)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                                .disabled(true)
                        }
                        .onAppear {
                            setMultiplierAndRotation(gameHelper.gameState!.num_teams, gameHelper.gameState!.num_players)
                        }
                    }
                default:
                    EmptyView()
            }
        }
    }
    
    var cribbage_userDraggedCards: some View {
        VStack {
            switch (gameHelper.gameState?.turn ?? gameObservable.game.turn) {
                case 1:
                    VStack {
                        determineTextForTurnOne()
                        Spacer()
                        HStack(spacing: 20) {
                            ForEach(cardsDragged, id: \.self) { card in
                                CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(false), backside: .constant(false), scale: Double(specs.maxY / 852))
                                    .transition(.offset())
                                    .onTapGesture {
                                        withAnimation {
                                            cardsDragged.removeAll(where: { $0 == card })
                                            cardsInHand.append(card)
                                        }
                                    }
                            }
                        }
                        .transition(.opacity)
                        
                        CustomButton(name: "Submit", submitFunction: {
                            guard gameHelper.gameState != nil else {
                                return
                            }
                            
                            if playerReady() {
                                Task {
                                    disableCardsDragged = true
                                    let tempCardsDragged = cardsDragged
//                                    cardsDragged.removeAll()
                                    await gameHelper.updateGame(["crib": tempCardsDragged], arrayAction: .append)
                                    await gameHelper.updatePlayer(["cards_in_hand": tempCardsDragged], arrayAction: .remove)
                                    await gameHelper.updatePlayer(["is_ready": true], arrayAction: .replace)
                                }
                            }
                        }, size: Int(specs.maxY / 60.85))
                    }
                    .disabled(disableCardsDragged)
                case 2:
                    VStack {
                        if gameHelper.gameState?.player_turn ?? gameObservable.game.player_turn == gameHelper.playerState?.player_num ?? 0 {
                            CText("Play a card!", size: Int(determineFont("Play a card!", Int(specs.maxX / 1.31), 16)))
                        } else {
                            CText("Waiting for other players...", size: Int(determineFont("Waiting for other players...", Int(specs.maxX / 1.31), 16)))
                        }
                        Spacer()
                        TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                            .onAppear {
                                cardsDragged = []

                                guard gameHelper.playerState != nil, gameHelper.playerState!.is_lead else {
                                    return
                                }
                                
                                // reinitialize fields used during play (turn 2)
                                Task {
                                    await gameHelper.updateGame([
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
                case 3, 4:
                    ZStack {
                        VStack {
                            CText("Time to score hands!", size: Int(determineFont("Time to score hands!", Int(specs.maxX / 1.31), 16)))
                                .foregroundStyle(specs.theme.colorWay.textColor)
                            Spacer()
                        }
                    }
//                case 4:
//                    ZStack {
//                        VStack {
//                            CText("and the crib!", size: Int(determineFont("and the crib!", Int(specs.maxX / 1.31), 16)))
//                                .foregroundStyle(specs.theme.colorWay.textColor)
//                            Spacer()
//                        }
//                    }
                default: EmptyView()
            }
        }
        .padding()
        .frame(/*width: specs.maxX / 1.31, */height: specs.maxY / 4.26)
        .background {
            if (gameHelper.gameState?.turn ?? gameObservable.game.turn) > 0 {
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(specs.theme.colorWay.primary, lineWidth: 5.0)
                    .fill(specs.theme.colorWay.background)
            }
        }
    }
    
    var cribbage_commonCardArea: some View {
        HStack(spacing: 30) {
            ZStack {
                HStack(spacing: cribSpacing) {
                    ForEach(Array(gameHelper.gameState?.crib.enumerated() ?? gameObservable.game.crib.enumerated()), id: \.offset) { (index, cardId) in
                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: $dontShowCrib)
                    }
                }
                .transition(.opacity)
                .zIndex(1.0)
                
                if gameHelper.gameState?.turn ?? gameObservable.game.turn == 4 {
                    VStack {
                        PointContainer(crib: true)
                            .scaleEffect(2.0)
                            .offset(y: -90)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                                    Task {
                                        await gameHelper.updatePlayer(["is_ready": true])
                                    }
                                })
                            }
                    }
                    .frame(height: 100)
                    .transition(.move(edge: .bottom).animation(.smooth.delay(1.0)))
                    .zIndex(0.0)
                }
            }

            ZStack {
                CardView(cardItem: CardItem(id: gameHelper.gameState?.starter_card ?? gameObservable.game.starter_card), cardIsDisabled: .constant(true), backside: $dontShowStarter, naturalOffset: true)
                    .offset(x: -0.1 * Double(cards.endIndex), y: -0.1 * Double(cards.endIndex))
                    .zIndex(1.0)
                    .disabled(true)

                DeckOfCardsView(cards: $cards)
                    .zIndex(0.0)
                    .disabled(true)
            }
        }
        .scaleEffect(0.75 * (specs.maxY / 852))
        .frame(width: 150, height: 100)
    }
    
   func determineCommonAreaPosition(turn: Int) -> CGFloat {
        if turn == 1 || turn == 4 {
            return specs.maxY * 0.57
        } else {
            return specs.maxY * 0.47
        }
    }
    
   func determineCribSpacing(turn: Int) -> CGFloat {
        if turn == 1 || turn == 4 {
            return -33
        } else {
            return -55
        }
    }
    
    func determineSubmitColor() -> Color {
        if disableCardsDragged {
            return .gray
        } else if playerReady() {
            return .green
        } else {
            return .red
        }
    }
    
    // used for turn one in cribbage
    func playerReady() -> Bool {
        switch (gameHelper.gameState?.num_players ?? gameObservable.game.num_players) {
            case 2:
                return cardsDragged.count == 2
            case 3, 4:
                return cardsDragged.count == 1
            case 6:
                if ((gameHelper.playerState?.player_num ?? 0) != (gameHelper.gameState?.dealer ?? gameObservable.game.dealer)
                    && (((gameHelper.playerState?.player_num ?? 0) + 1) % (gameHelper.gameState?.num_players ?? gameObservable.game.num_players)) != (gameHelper.gameState?.dealer ?? gameObservable.game.dealer)) {
                    return cardsDragged.count == 1
                } else {
                    disableCardsDragged = true
                    return cardsDragged.count == 0
                }
            default:
                return false
        }
    }
    
    // used for turn one in cribbage
    func determineTextForTurnOne() -> some View {
        ZStack {
            switch (gameHelper.gameState?.num_players ?? gameObservable.game.num_players) {
                case 2, 4:
                    if playerReady() && disableCardsDragged {
                        CText("Waiting for players to discard...", size: Int(determineFont("Waiting for players to discard...", Int(specs.maxX / 1.31), 16)))
                    } else {
                        CText("Send \(gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!", size: Int(determineFont("Send \(gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!", Int(specs.maxX / 1.31), 16)))
                    }
                case 3:
                    if playerReady() && disableCardsDragged {
                        CText("Waiting for players to discard...", size: Int(determineFont("Waiting for players to discard...", Int(specs.maxX / 1.31), 16)))
                    } else {
                        CText("Send \(gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!", size: Int(determineFont("Send \(gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!", Int(specs.maxX / 1.31), 16)))
                    }
                case 6:
                    if playerReady() && disableCardsDragged {
                        CText("Waiting for players to discard...", size: Int(determineFont("Waiting for players to discard...", Int(specs.maxX / 1.31), 16)))
                    } else {
                        CText("Send \(gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!", size: Int(determineFont("Send \(gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!", Int(specs.maxX / 1.31), 16)))
                    }
                default:
                    CText("Shouldn't have got here")
            }
        }
    }
    
    func determineNumberOfCards() -> String {
        switch (gameHelper.gameState?.game_name ?? gameObservable.game.game_name) {
            case "cribbage":
                if gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 2
                    || gameHelper.gameState?.num_players ?? gameObservable.game.num_players == 4 {
                    return "two cards"
                } else {
                    return "one card"
                }
            default:
                return "no cards"
        }
    }
    
    func setMultiplierAndRotation(_ numTeams: Int, _ numPlayers: Int) {
//        if let gameState = gameHelper.gameState {
            switch numTeams {
                case 2:
                    if numPlayers == 2 {
                        startingRotation = 0
                        multiplier = 0
                    } else {
                        startingRotation = 270
                        multiplier = 90
                    }
                case 3:
                    if numPlayers == 3 {
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
//        } else {
//            startingRotation = 240
//            multiplier = 60
//        }
    }
}

#Preview {
    return GeometryReader { geo in
        CardsView(gameObservable: GameObservable(game: .game))
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
//            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(Color("OffWhite").opacity(0.1))
        
    }
    .ignoresSafeArea()
}
