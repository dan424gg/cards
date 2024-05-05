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
            Text("View Players Hands")
                .font(.custom("LuckiestGuy-Regular", size: 32))
                .foregroundStyle(.white)

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
            
            Button {
                Task {
                    await firebaseHelper.updatePlayer(["is_ready": true])
                }
            } label: {
                Text("Ready Up")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .font(.custom("LuckiestGuy-Regular", size: 24))
                    .baselineOffset(-5)
                    .foregroundStyle(specs.theme.colorWay.primary)
                    .background(specs.theme.colorWay.white)
                    .clipShape(Capsule())
            }
        }
        .frame(width: specs.maxX, height: specs.maxY)
        .sheet(isPresented: $showSheet, content: {
            PlayerHand(player: $expandedPlayer)
                .presentationDetents([.fraction(0.69)])
                .presentationBackground(content: {
//                    if expandedPlayer.is_ready {
//                        specs.theme.colorWay.primary
//                    } else {
                        VisualEffectView(effect: UIBlurEffect(style: .regular))
//                    }
                })
                .presentationCornerRadius(25.0)
                .presentationDragIndicator(.visible)
        })
    }
    
    struct PlayerNameButton: View {
        @EnvironmentObject var firebaseHelper: FirebaseHelper
        @EnvironmentObject var specs: DeviceSpecs
        @State var points = 0
        @State var cribPoints = -1
        @StateObject var gameObservable: GameObservable = GameObservable(game: .game)

        @Binding var player: PlayerState
        
        var body: some View {
            HStack {
                PlayerView(player: .constant(player), index: 0, playerTurn: 0, fontSize: 24)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Text("\(points)")
                        .font(.custom("LuckiestGuy-Regular", size: 24))
                        .baselineOffset(-6)
                        .foregroundStyle(.white)
                    
                    Text("\(cribPoints != -1 ? " + \(cribPoints)" : "")")
                        .baselineOffset(-6)
                        .font(.custom("LuckiestGuy-Regular", size: 24))
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.horizontal)
//            .padding(.vertical, 15)
            .frame(width: specs.maxX * 0.7, height: 60)
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .fill(player.is_ready ? specs.theme.colorWay.primary : .black.opacity(0.15))
            }
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

//    var player: PlayerState
    
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
            Text("\(player.name)'s Hand")
                .underline()
                .font(.custom("LuckiestGuy-Regular", size: 21))
                .baselineOffset(-6)
                .foregroundStyle(.white)
            
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
            RoundedRectangle(cornerRadius: 20.0)
                .fill(player.is_ready ? specs.theme.colorWay.primary.opacity(0.9) : .black.opacity(0.4))
        }
    }

    var cribHandArea: some View {
        VStack {
            Text("\(player.name)'s Crib")
                .underline()
                .font(.custom("LuckiestGuy-Regular", size: 21))
                .baselineOffset(-6)
                .foregroundStyle(.yellow)
            
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
            RoundedRectangle(cornerRadius: 20.0)
                .fill(player.is_ready ? specs.theme.colorWay.primary.opacity(0.9) : .black.opacity(0.4))
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
            PlayerView(player: .constant(player), index: 0, playerTurn: 0, fontSize: 24)
            
            HStack(spacing: 0) {
                Text("\(points)")
                    .font(.custom("LuckiestGuy-Regular", size: 24))
                    .foregroundStyle(.white)
                
                Text("\(cribPoints != -1 ? " + \(cribPoints)" : "")")
                    .font(.custom("LuckiestGuy-Regular", size: 24))
                    .foregroundStyle(.yellow)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(player.is_ready ? specs.theme.colorWay.primary.opacity(0.9) : .black.opacity(0.4))
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
                Text("\(hand.pointsCallOut)")
                    .font(.custom("LuckiestGuy-Regular", size: 21))
                    .baselineOffset(-6)
                    .foregroundStyle(crib ? .yellow : .white)
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
//    .ignoresSafeArea()
}
