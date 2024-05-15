//
//  PlayersHandsView.swift
//  Cards
//
//  Created by Daniel Wells on 4/12/24.
//

import SwiftUI

struct PlayersHandsView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)
    @State var expandedPlayer: PlayerState = PlayerState()
    @State var showSheet: Bool = false
    @State var players: [PlayerState] = []

    var body: some View {
        VStack(spacing: 56) {
            CText("View Players Hands", size: 32)

            VStack(spacing: 15) {
                if players != [] {
                    ForEach($players, id: \.self) { player in
                        PlayerNameButton(player: player)
                            .onTapGesture {
                                showSheet = true
                                expandedPlayer = player.wrappedValue
                            }
                    }
                }
            }
            .onChange(of: firebaseHelper.players, initial: true, {
                guard firebaseHelper.players != [] else {
                    players = GameState.players
                    players.append(PlayerState.player_one)
                    return
                }
                
                withAnimation {
                    players = firebaseHelper.players
                    players.append(firebaseHelper.playerState!)
                    players.sort(by: { $0.player_num < $1.player_num })
                }
            })
            
            .onChange(of: firebaseHelper.playerState, {
                guard firebaseHelper.playerState != nil else {
                    return
                }
                
                withAnimation {
                    players = firebaseHelper.players
                    players.append(firebaseHelper.playerState!)
                    players.sort(by: { $0.player_num < $1.player_num })
                }
            })
            
            CustomButton(name: "Ready Up", submitFunction: {
                guard firebaseHelper.playerState != nil else {
                    return
                }
                
                if firebaseHelper.playerState!.is_ready {
                    Task {
                        await firebaseHelper.updatePlayer(["is_ready": false])
                    }
                } else {
                    Task {
                        await firebaseHelper.updatePlayer(["is_ready": true])
                    }
                }
            })
        }
        .frame(width: specs.maxX, height: specs.maxY)
        .sheet(isPresented: $showSheet, content: {
            PlayerHand(player: $expandedPlayer)
                .presentationDetents([.fraction(0.69)])
                .presentationBackground(content: {
//                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                    specs.theme.colorWay.background
                })
                .presentationCornerRadius(25.0)
                .presentationDragIndicator(.visible)
        })
    }
}

struct PlayerNameButton: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State var points = 0
    @State var cribPoints = -1
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)

    @Binding var player: PlayerState
    
    @State var bool: Bool = false
    
    var body: some View {
        HStack {
            if player.is_ready {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50, weight: .regular))
                    .foregroundStyle(specs.theme.colorWay.primary, specs.theme.colorWay.secondary)
                Spacer()
            }
            
            HStack {
                CText(player.name)
                if (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer) == player.player_num {
                    CribMarker(scale: 0.6)
                        .disabled(true)
                }
                
                Spacer()
                
                HStack(spacing: 0) {
                    CText("\(points)", size: 24)
                    
                    CText("\(cribPoints != -1 ? " + \(cribPoints)" : "")", size: 24)
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.horizontal)
            .frame(height: 60)
            .background {
                specs.theme.colorWay.primary
                    .clipShape(Capsule())
            }
        }
        .transition(.offset())
        .animation(.smooth, value: player.is_ready)
        .frame(width: specs.maxX * 0.8, height: 60)
        .onAppear {
            let playerScoringHands = firebaseHelper.checkCardsForPoints(playerCards: player.cards_in_hand, firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card)
            
            if let lastScoringHand = playerScoringHands.last {
                points = lastScoringHand.cumlativePoints
            } else {
                points = 0
            }
            
            if (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer) == player.player_num {
                let cribScoringHands = firebaseHelper.checkCardsForPoints(crib: firebaseHelper.gameState?.crib ?? gameObservable.game.crib, firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card)
                
                if let lastScoringHand = cribScoringHands.last {
                    cribPoints = lastScoringHand.cumlativePoints
                } else {
                    cribPoints = 0
                }
            }
        }
    }
}

struct PlayerHand: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @Namespace var playerHandViewNS
    @StateObject var gameObservable: GameObservable = GameObservable(game: .game)

    @State var points: Int = -1
    @State var playerScoringHands: [ScoringHand] = []
    @State var cribPoints: Int = -1
    @State var cribScoringHands: [ScoringHand] = []
    @Binding var player: PlayerState
    
    var body: some View {
        VStack {
            playerIndicator(expandedPlayer: $player)
            
            ScrollView(.vertical, showsIndicators: false) {
                playerHandsArea
                
                if (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer) == player.player_num {
                    cribHandArea
                }
            }
            .frame(width: specs.maxX * 0.8)
        }
        .padding(.vertical, 20)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            playerScoringHands = firebaseHelper.checkCardsForPoints(playerCards: player.cards_in_hand, firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card)
            
            if let lastScoringHand = playerScoringHands.last {
                points = lastScoringHand.cumlativePoints
            } else {
                points = 0
            }
            
            if (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer) == player.player_num {
                cribScoringHands = firebaseHelper.checkCardsForPoints(crib: firebaseHelper.gameState?.crib ?? gameObservable.game.crib, firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card)
                
                if let lastScoringHand = cribScoringHands.last {
                    cribPoints = lastScoringHand.cumlativePoints
                } else {
                    cribPoints = 0
                }
            }
        }
    }
    
    var playerHandsArea: some View {
        VStack {
            CText("\(player.name)'s Hand", size: 21)
                .underline()
//                .font(.custom("LuckiestGuy-Regular", size: 21))
//                .baselineOffset(-6)
//                .foregroundStyle(.white)
            
            Spacer()
                .frame(height: 10)
            
            handAndStarter(cards: player.cards_in_hand)
            
            Spacer()
                .frame(height: 25)
            
            playerScoringHandsView
        }
        .padding(.top, 10)
        .padding([.leading, .trailing, .bottom], 25)
        .background {
            specs.theme.colorWay.primary
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
        }
    }

    var cribHandArea: some View {
        VStack {
            CText("\(player.name)'s Crib", size: 21)
                .foregroundStyle(.yellow)
                .underline()
            
            Spacer()
                .frame(height: 10)
            
            handAndStarter(cards: firebaseHelper.gameState?.crib ?? gameObservable.game.crib)
            
            Spacer()
                .frame(height: 25)
            
            cribScoringHandsView
        }
        .padding(.top, 10)
        .padding([.leading, .trailing, .bottom], 25)
        .background {
            specs.theme.colorWay.primary
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
        }
    }
    
    var cribScoringHandsView: some View {
        VStack {
            VStack {
                ForEach(cribScoringHands, id: \.self) { hand in
                    scoredHand(hand: hand, crib: true)
                }
            }
        }
    }
    
    func playerIndicator(expandedPlayer: Binding<PlayerState>) -> some View {
        VStack {
            HStack {
                CText(player.name)
                if (firebaseHelper.gameState?.dealer ?? gameObservable.game.dealer) == player.player_num {
                    CribMarker(scale: 0.6)
                        .disabled(true)
                }
            }

            HStack(spacing: 0) {
                CText("\(points)", size: 24)
                
                CText("\(cribPoints != -1 ? " + \(cribPoints)" : "")", size: 24)
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background {
            specs.theme.colorWay.primary
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
        }
    }

    func handAndStarter(cards: [Int]) -> some View {
        HStack {
            HStack(spacing: -20) {
                ForEach(cards, id: \.self) { card in
                    CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(true), backside: .constant(false))
                }
            }
            Spacer()
            CardView(cardItem: CardItem(id: firebaseHelper.gameState?.starter_card ?? gameObservable.game.starter_card), cardIsDisabled: .constant(true), backside: .constant(false))
        }
        .frame(width: 280)  // same width as playerScoringHands
    }
    
    var playerScoringHandsView: some View {
        VStack {
            VStack {
                ForEach(playerScoringHands, id: \.self) { hand in
                    scoredHand(hand: hand)
                }
            }
        }
    }
    
    func scoredHand(hand: ScoringHand, crib: Bool = false) -> some View {
        HStack {
            HStack(spacing: -40) {
                ForEach(hand.cardsInScoredHand, id: \.self) { card in
                    CardView(cardItem: CardItem(id: card), cardIsDisabled: .constant(true), backside: .constant(false))
                }
            }
            .frame(width: 140, alignment: .leading)
            
            HStack {
                Spacer()
                CText("\(hand.pointsCallOut)", size: 21)
                    .foregroundStyle(crib ? .yellow : nil)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .frame(width: 140, alignment: .trailing)
        }
        .frame(width: 280, alignment: .leading)
    }
}

#Preview {
    return GeometryReader { geo in
        PlayersHandsView()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
}
