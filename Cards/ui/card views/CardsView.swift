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
    @StateObject var gameObservable: GameObservable/* = GameObservable(game: .game)*/
    @State var cards: [Int] = []
    @State var cardsInHand: [Int] = []
    @State var cardsDragged: [Int] = []
    
    @State var disableCardsDragged: Bool = false
    
    @State var dontShowCrib: Bool = true
    @State var dontShowStarter: Bool = true
    @State var cribYPosition: CGFloat = -1.0
    @State var cribSpacing: CGFloat = -1.0
    @State var i: Int = -1
    
    var body: some View {
        ZStack {
//            Button("change players") {
//                i = (i + 1) % 4
//                
//                if i == 0 {
//                    GameState.players = [PlayerState.player_two]
//                    gameObservable.game.num_teams = 2
//                    gameObservable.game.num_players = 2
//                } else if i == 1 {
//                    GameState.players = [PlayerState.player_two, PlayerState.player_three]
//                    gameObservable.game.num_teams = 3
//                    gameObservable.game.num_players = 3
//                } else if i == 2 {
//                    GameState.players = [PlayerState.player_two, PlayerState.player_three, PlayerState.player_four]
//                    gameObservable.game.num_teams = 2
//                    gameObservable.game.num_players = 4
//                } else if i == 3 {
//                    GameState.players = [PlayerState.player_two, PlayerState.player_three, PlayerState.player_four, PlayerState.player_five, PlayerState.player_six]
//                    gameObservable.game.num_teams = 3
//                    gameObservable.game.num_players = 6
//                }
//            }
//            .buttonStyle(.bordered)
//            .offset(x: -150, y: 200)
//

            
            switch (firebaseHelper.gameState?.game_name ?? "cribbage") {
                case "cribbage":
                    cribbage_userDraggedCards
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.69)
                        .offset(y: 50)
                    
                    cribbage_otherPlayersCards
                        .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                        .zIndex(1.0)
                    
                    cribbage_commonCardArea
                        .onAppear {
                            cribSpacing = -33
                            cribYPosition = specs.maxY * 0.5
                        }
                        .onChange(of: firebaseHelper.gameState?.turn, initial: true, { (_, new) in
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
                .position(x: specs.maxX / 2, y: specs.maxY * 1.07)
                .zIndex(1.0)
                .offset(y: 50)
        }
        .onChange(of: firebaseHelper.gameState?.cards, { (_, new) in
            guard new != nil else {
                return
            }
            
            cards = new!
        })
        .onChange(of: firebaseHelper.playerState?.cards_in_hand, initial: true, {
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
        .onChange(of: firebaseHelper.gameState?.turn, initial: true, { (_, new) in
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
            switch (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
                case 0, 1:
                    if firebaseHelper.players == [] {
                        ForEach(Array(GameState.players.enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: .constant(player.cards_in_hand), showBackside: true)
                                .scaleEffect(0.3)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.18)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onChange(of: GameState.players, initial: true, {
                            setMultiplierAndRotation(gameObservable.game.num_teams, gameObservable.game.num_players)
                        })
                    } else {
                        ForEach(Array($firebaseHelper.players.enumerated()), id: \.offset) { (index, player) in
                            CardInHandArea(cards: $cards, cardsDragged: .constant([]), cardsInHand: player.cards_in_hand, showBackside: true)
                                .scaleEffect(0.3)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.18)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation(firebaseHelper.gameState!.num_teams, firebaseHelper.gameState!.num_players)
                        }
                    }
                case 2:
                    if firebaseHelper.players == [] {
                        ForEach(Array(GameState.players.enumerated()), id: \.offset) { (index, player) in
                            TurnTwoView(cardsDragged: .constant(player.cards_dragged), cardsInHand: .constant([]), otherPlayer: true, otherPlayerPointCallOut: player.callouts, otherPlayerTeamNumber: player.team_num)
                                .scaleEffect(0.7)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.15)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onChange(of: GameState.players, initial: true, {
                            setMultiplierAndRotation(gameObservable.game.num_teams, gameObservable.game.num_players)
                        })
                    } else {
                        ForEach(Array($firebaseHelper.players.enumerated()), id: \.offset) { (index, player) in
                            TurnTwoView(cardsDragged: player.cards_dragged, cardsInHand: .constant([]), otherPlayer: true, otherPlayerPointCallOut: player.callouts.wrappedValue, otherPlayerTeamNumber: player.team_num.wrappedValue)
                                .scaleEffect(0.7)
                                .rotationEffect(.degrees(-180.0))
                                .offset(y: -specs.maxY * 0.15)
                                .rotationEffect(.degrees(Double(startingRotation + (multiplier * index))))
                        }
                        .onAppear {
                            setMultiplierAndRotation(firebaseHelper.gameState!.num_teams, firebaseHelper.gameState!.num_players)
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
                            setMultiplierAndRotation(gameObservable.game.num_teams, gameObservable.game.num_players)
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
                            setMultiplierAndRotation(firebaseHelper.gameState!.num_teams, firebaseHelper.gameState!.num_players)
                        }
                    }
                default:
                    EmptyView()
            }
        }
    }
    
    var cribbage_userDraggedCards: some View {
        VStack {
            switch (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
                case 1:
                    VStack {
                        determineTextForTurnOne()
                        Spacer()
                        HStack(spacing: 20) {
                            ForEach(cardsDragged, id: \.self) { card in
                                CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(true), backside: .constant(false))
                                    // .matchedGeometryEffect(id: card, in: namespace, properties: .position)
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
                        
                        Button {
                            guard firebaseHelper.gameState != nil else {
                                return
                            }
                            
                            if playerReady() {
                                Task {
                                    disableCardsDragged = true
                                    let tempCardsDragged = cardsDragged
                                    cardsDragged.removeAll()
                                    await firebaseHelper.updateGame(["crib": tempCardsDragged], arrayAction: .append)
                                    await firebaseHelper.updatePlayer(["cards_in_hand": tempCardsDragged], arrayAction: .remove)
                                    await firebaseHelper.updatePlayer(["is_ready": true], arrayAction: .replace)
                                }
                            } else {
                                // show error
                            }
                        } label: {
                            Text("Submit")
                                .foregroundStyle(determineSubmitColor())
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .baselineOffset(-5)
                        }
                        .frame(width: 80, height: 32)
                        .background {
                            VisualEffectView(effect: UIBlurEffect(style: .prominent))
                                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        }
                    }
                    .disabled(disableCardsDragged)
                case 2:
                    VStack {
                        if firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn == firebaseHelper.playerState?.player_num ?? 0 {
                            Text("Play a card!")
                                .foregroundStyle(specs.theme.colorWay.textColor)
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .baselineOffset(-1.6)
                        } else {
                            Text("Waiting for other players...")
                                .foregroundStyle(specs.theme.colorWay.textColor)
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .baselineOffset(-1.6)
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
                case 3:
                    ZStack {
                        VStack {
                            Text("Time to score hands!")
                                .foregroundStyle(specs.theme.colorWay.textColor)
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .baselineOffset(-1.6)
                            Spacer()
                        }
                    }
                case 4:
                    ZStack {
                        VStack {
                            CText("and the crib!")
                                .foregroundStyle(specs.theme.colorWay.textColor)
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .baselineOffset(-1.6)
                            Spacer()
                        }
                    }
                default: EmptyView()
            }
        }
        .padding()
        .background {
            if (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) > 0 {
                RoundedRectangle(cornerRadius: 25.0)
                    .stroke(specs.theme.colorWay.primary, lineWidth: 5.0)
                    .fill(specs.theme.colorWay.background)
            }
        }
        .frame(width: 300, height: 200)
    }
    
    var cribbage_commonCardArea: some View {
        HStack(spacing: 30) {
            ZStack {
                HStack(spacing: cribSpacing) {
                    ForEach(Array(firebaseHelper.gameState?.crib.enumerated() ?? gameObservable.game.crib.enumerated()), id: \.offset) { (index, cardId) in
                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(false), backside: $dontShowCrib)
                    }
                }
                .transition(.opacity)
                .zIndex(1.0)
                
                if firebaseHelper.gameState?.turn ?? gameObservable.game.turn == 4 {
                    VStack {
                        PointContainer(crib: true)
                            .scaleEffect(2.0)
                            .offset(y: -90)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                                    Task {
                                        await firebaseHelper.updatePlayer(["is_ready": true])
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
                CardView(cardItem: CardItem(id: firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card), cardIsDisabled: .constant(true), backside: $dontShowStarter, naturalOffset: true)
                    .offset(x: -0.1 * Double(cards.endIndex), y: -0.1 * Double(cards.endIndex))
                    .zIndex(1.0)
                
                DeckOfCardsView(cards: $cards)
                    .zIndex(0.0)
            }
        }
        .scaleEffect(0.75)
        .frame(width: 150, height: 100)
    }
    
   func determineCommonAreaPosition(turn: Int) -> CGFloat {
        if turn == 1 || turn == 4 {
            return specs.maxY * 0.57
        } else {
            return specs.maxY * 0.5
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
        switch (firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players) {
            case 2, 4:
                return cardsDragged.count == 2
            case 3:
                return cardsDragged.count == 1
            case 6:
                if ((firebaseHelper.playerState?.player_num ?? 0) != (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer)
                    && (((firebaseHelper.playerState?.player_num ?? 0) + 1) % (firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players)) != (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer)) {
                    return cardsDragged.count == 1
                } else {
                    return cardsDragged.count == 0
                }
            default:
                return false
        }
    }
    
    // used for turn one in cribbage
    func determineTextForTurnOne() -> some View {
        ZStack {
            switch (firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players) {
                case 2, 4:
                    if playerReady() && disableCardsDragged {
                        Text("Waiting for players to discard...")
                            .font(.custom("LuckiestGuy-Regular", size: 16))
                            .baselineOffset(-1.6)
                    } else {
                        Text("Send \(firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!")
                            .font(.custom("LuckiestGuy-Regular", size: 16))
                            .baselineOffset(-1.6)
                    }
                case 3:
                    if playerReady() && disableCardsDragged {
                        Text("Waiting for players to discard...")
                            .font(.custom("LuckiestGuy-Regular", size: 16))
                            .baselineOffset(-1.6)
                    } else {
                        Text("Send \(firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!")
                            .font(.custom("LuckiestGuy-Regular", size: 16))
                            .baselineOffset(-1.6)
                    }
                case 6:
                    if playerReady() && disableCardsDragged {
                        Text("Waiting for players to discard...")
                            .font(.custom("LuckiestGuy-Regular", size: 16))
                            .baselineOffset(-1.6)
                    } else {
                        Text("Send \(firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 2 ? "two cards" : "one card") to the crib!")
                            .font(.custom("LuckiestGuy-Regular", size: 16))
                            .baselineOffset(-1.6)
                    }
                default:
                    Text("Shouldn't have got here")
            }
        }
        .foregroundStyle(.white)
    }
    
    func determineNumberOfCards() -> String {
        switch (firebaseHelper.gameState?.game_name ?? gameObservable.game.game_name) {
            case "cribbage":
                if firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 2
                    || firebaseHelper.gameState?.num_players ?? gameObservable.game.num_players == 4 {
                    return "two cards"
                } else {
                    return "one card"
                }
            default:
                return "no cards"
        }
    }
    
    func setMultiplierAndRotation(_ numTeams: Int, _ numPlayers: Int) {
//        if let gameState = firebaseHelper.gameState {
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
