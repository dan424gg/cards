//
//  GameView.swift
//  Cards
//
//  Created by Daniel Wells on 11/7/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @Namespace var cardsNS
    @State var showSnackbar: Bool = true
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    @State var initial = true
    @State var shown: Bool = false          // for cribbage
    @State var playingGame: Bool = true    // for cribbage

    var body: some View {
        ZStack {
//            ZStack {
//                specs.theme.colorWay.background
//                ForEach(Array(0...20), id: \.self) { i in
//                    LineOfSuits(index: i)
//                        .offset(y: CGFloat(-120 * Double(i)))
//                }
//                .position(x: specs.maxX / 2, y: specs.maxY * 1.5)
//            }
//            .zIndex(0.0)            
            Button("incr turn") {
                withAnimation {
                    gameObservable.game.player_turn = (gameObservable.game.player_turn + 1) % 6
                }
            }
            .buttonStyle(.bordered)
            .offset(x: 150, y: 200)
            
            if (firebaseHelper.gameState?.turn ?? gameObservable.game.turn) != 6 {
                if playingGame {
                    Group {
                        PlayingTable(gameObservable: gameObservable)
                            .frame(height: specs.maxY * 0.4)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                            .offset(y: -50)
//                            .background {
//                                specs.theme.colorWay.background
//                            }
                        
                        PlayerIndicator(gameObservable: gameObservable)
                            .frame(height: specs.maxY * 0.4)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                            .offset(y: -50)
                        
                        NamesAroundTable(gameObservable: gameObservable)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                            .offset(y: -50)
                        
                        CribbageBoard()
                            .scaleEffect(x: 0.8, y: 0.8)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.4 )
                            .offset(y: -50)
                        
                        CardsView(gameObservable: gameObservable)
                            .offset(y: -50)
                        
                        if firebaseHelper.gameState?.dealer == firebaseHelper.playerState?.player_num {
                            CribMarker()
                                .position(x: specs.maxX * 0.90, y: specs.maxY * 0.95)
                                .transition(.opacity)
                        }
                        
                        if shown {
                            PointContainer(player: firebaseHelper.playerState ?? PlayerState.player_one, user: true)
                                .position(x: specs.maxX / 2, y: specs.maxY * 0.68)
                                .transition(.opacity)
                        }
                        
                        GameOutcomeView(outcome: $firebaseHelper.gameOutcome)
                    }
                    .geometryGroup()
                    .clipped()
                    .transition(.move(edge: .top))
                } else {
                    PlayersHandsView()
                        .geometryGroup()
                        .transition(.move(edge: .bottom))
                }
            } else {
                ProgressView()
                    .padding()
                    .background {
                        VisualEffectView(effect: UIBlurEffect(style: .regular))
                            .clipShape(RoundedRectangle(cornerRadius: 5.0))
                    }
                    .tint(.white)
                    .scaleEffect(2.0)
                    .position(x: specs.maxX / 2, y: specs.maxY / 2)
                    .transition(.opacity)
            }
        }
        .disabled(firebaseHelper.gameOutcome != .undetermined)
        .onChange(of: firebaseHelper.playerState?.is_ready, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil, firebaseHelper.playerState!.is_lead else {
                return
            }
            
            if firebaseHelper.playersAreReady() {
                Task {
                    if firebaseHelper.gameState!.turn == 5 {
                        do { try await Task.sleep(nanoseconds: UInt64(1500000000)) } catch { print(error) }
                    }
                    await firebaseHelper.unreadyAllPlayers()
                    await firebaseHelper.updateGame(["turn": (firebaseHelper.gameState!.turn + 1) % 7])
                }
            }
        })
        .onChange(of: firebaseHelper.players, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil, firebaseHelper.playerState!.is_lead else {
                return
            }
            
            if firebaseHelper.playersAreReady() {
                Task {
                    if firebaseHelper.gameState!.turn == 5 {
                        do { try await Task.sleep(nanoseconds: UInt64(1500000000)) } catch { print(error) }
                    }
                    await firebaseHelper.unreadyAllPlayers()
                    await firebaseHelper.updateGame(["turn": (firebaseHelper.gameState!.turn + 1) % 7])
                }
            }
        })
        .onChange(of: firebaseHelper.teamState?.points, {
            guard firebaseHelper.teamState != nil else {
                return
            }
            
            if firebaseHelper.teamState!.points >= 121 {
                Task {
                    await firebaseHelper.updateGame(["who_won": firebaseHelper.teamState!.team_num])
                }
                firebaseHelper.gameOutcome = .win
            }
        })
        .onChange(of: firebaseHelper.gameState?.who_won,  {
            guard firebaseHelper.gameState != nil, firebaseHelper.teamState != nil else {
                return
            }
            
            if firebaseHelper.teamState!.team_num == firebaseHelper.gameState!.who_won {
                firebaseHelper.gameOutcome = .win
            } else {
                firebaseHelper.gameOutcome = .lose
            }
        })
        .onChange(of: firebaseHelper.gameState?.turn, initial: true, {
            guard firebaseHelper.gameState != nil else {
                return
            }
            
            if firebaseHelper.gameState!.turn == -1 {
                guard firebaseHelper.playerState != nil, firebaseHelper.playerState!.is_lead else {
                    return
                }
                
                Task(priority: .userInitiated) {
                    let randDealer = Int.random(in: 0..<(firebaseHelper.gameState!.num_players))
                    
                    // determine dealer's team for crib
                    if let teamWithCrib = firebaseHelper.players.first(where: { $0.player_num == randDealer })?.team_num {
                        await firebaseHelper.updateGame(["dealer": randDealer, "team_with_crib": teamWithCrib])
                    } else {
                        let teamWithCrib = firebaseHelper.playerState!.team_num
                        await firebaseHelper.updateGame(["dealer": randDealer, "team_with_crib": teamWithCrib])
                    }
                    
                    await firebaseHelper.updateGame(["turn": 0])
                }
            } else if firebaseHelper.gameState!.turn == 0 {
                withAnimation {
                    playingGame = true
                }
                
                guard firebaseHelper.playerState!.player_num == firebaseHelper.gameState!.dealer else {
                    return
                }
                
                Task {
                    await firebaseHelper.shuffleAndDealCards()
                    await firebaseHelper.updateGame(["turn": 1])
                }
                
            } else if firebaseHelper.gameState!.turn == 2 {
                guard firebaseHelper.gameState != nil, firebaseHelper.playerState != nil, firebaseHelper.playerState!.is_lead else {
                    return
                }
                Task {
                    await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.dealer + 1) % firebaseHelper.gameState!.num_players])
                }
            } else if firebaseHelper.gameState!.turn == 3 {
                let numPlayers = firebaseHelper.gameState!.num_players
                
                for i in 0...numPlayers {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i + 1) * 1.5), execute: {
                        if i == numPlayers {
                            Task {
                                await firebaseHelper.updatePlayer(["is_ready": true])
                            }
                        } else if i == 0 {
                            // UPDATING GAMESTATE LOCALLY
                            firebaseHelper.gameState!.player_turn = (firebaseHelper.gameState!.dealer + 1) % numPlayers
                            if firebaseHelper.playerState!.player_num == firebaseHelper.gameState!.player_turn {
                                withAnimation {
                                    shown = true
                                }
                            }
                        } else {
                            // UPDATING GAMESTATE LOCALLY
                            firebaseHelper.gameState!.player_turn = (firebaseHelper.gameState!.player_turn + 1) % numPlayers
                            if firebaseHelper.playerState!.player_num == firebaseHelper.gameState!.player_turn {
                                withAnimation {
                                    shown = true
                                }
                            }
                        }
                    })
                }
            } else if firebaseHelper.gameState!.turn == 5 {
                withAnimation {
                    shown = false
                    playingGame = false
                }
            } else if firebaseHelper.gameState!.turn == 6 {
                guard firebaseHelper.playerState != nil, firebaseHelper.playerState!.is_lead else {
                    return
                }
                
                Task {
                    await firebaseHelper.resetGame()
                    try await Task.sleep(nanoseconds: UInt64(2.0 * Double(NSEC_PER_SEC)))
                    await firebaseHelper.updateGame(["turn": (firebaseHelper.gameState!.turn + 1) % 7])
                }
            }
        })
    }
    
    struct PlayingTable: View {
        @EnvironmentObject var firebaseHelper: FirebaseHelper
        @EnvironmentObject var specs: DeviceSpecs
        @StateObject var gameObservable: GameObservable
        
        var turn: Int {
            if firebaseHelper.gameState != nil {
                return firebaseHelper.gameState!.turn
            } else {
                return gameObservable.game.turn
            }
        }
        
        var body: some View {
//            ZStack {
//                if turn == 1 || turn == 4 {
                    Circle()
                        .trim(from: 0.0, to: turn == 1 || turn == 4 ? 0.75 : 1.0)
                        .rotation(.degrees(135))
                        .stroke(specs.theme.colorWay.primary, lineWidth: 3)
                        .fill(specs.theme.colorWay.background)
//                } else {
//                    Circle()
//                        .stroke(specs.theme.colorWay.white, lineWidth: 3)
//                }
//            }
        }
    }
    
    struct PlayerIndicator: View {
        @EnvironmentObject var firebaseHelper: FirebaseHelper
        @EnvironmentObject var specs: DeviceSpecs
        @State var initialRotation: Int = 0
        @State var multiplier: Int = 0
        @State var rotation: Double = 90.0
        @State var sortedPlayerNumList: [Int] = []
        @StateObject var gameObservable: GameObservable
        
        var turn: Int {
            if firebaseHelper.gameState != nil {
                return firebaseHelper.gameState!.turn
            } else {
                return gameObservable.game.turn
            }
        }
        
        var playerTurn: Int {
            if firebaseHelper.gameState != nil {
                return firebaseHelper.gameState!.player_turn
            } else {
                return gameObservable.game.player_turn
            }
        }
        
        var body: some View {
            if turn == 2 && playerTurn != -1 {
                Circle()
                    .trim(from: 0.0, to: 0.09375)
                    .rotation(.degrees(-16.875 + 90.0))
                    .stroke(specs.theme.colorWay.secondary, lineWidth: 3)
                    .rotationEffect(.degrees(Double(rotation)))
                    .transition(.opacity)
                    .onAppear {
                        if firebaseHelper.gameState != nil {
                            // set multiplier based on number of players
                            multiplier = 360 / firebaseHelper.gameState!.num_players
                            var players = firebaseHelper.players
                            players.append(firebaseHelper.playerState!)
                            players.sort(by: { $0.player_num < $1.player_num })
                            
                            // reorder player list to match playerViews
                            let beforePlayer = players[0..<firebaseHelper.playerState!.player_num]
                            let afterPlayer = players[firebaseHelper.playerState!.player_num..<players.count]
                            
                            sortedPlayerNumList = Array(afterPlayer + beforePlayer).map({ $0.player_num })
                            
                            // find index of player's turn
                            if let idx = sortedPlayerNumList.firstIndex(where: { $0 == firebaseHelper.gameState!.player_turn }) {
                                rotation = Double(idx * multiplier)
                            }
                        } else {
                            // set multiplier based on number of players
                            multiplier = 360 / gameObservable.game.num_players
                            var players = GameState.players
                            players.append(PlayerState.player_one)
                            players.sort(by: { $0.player_num < $1.player_num })
                            
                            // reorder player list to match playerViews
                            let beforePlayer = players[0..<1]
                            let afterPlayer = players[1..<players.count]
                            
                            sortedPlayerNumList = Array(afterPlayer + beforePlayer).map({ $0.player_num })
//                            sortedPlayerNumList = players.map({ $0.player_num })
                            
                            // find index of player's turn
                            if let idx = sortedPlayerNumList.firstIndex(where: { $0 == gameObservable.game.player_turn }) {
                                rotation = Double(idx * multiplier)
                            }
                        }
                    }
                    .onChange(of: playerTurn, {
                        withAnimation {
                            rotation += Double(multiplier)
                        }
                    })
            }
        }
        
//        func setRotation(_ gameState: GameState) -> CGFloat {
//            var playerState: PlayerState {
//                if firebaseHelper.playerState != nil {
//                    return firebaseHelper.playerState!
//                } else {
//                    return PlayerState.player_one
//                }
//            }
//            
//            switch gameState.num_teams {
//                case 2:
//                    if gameState.num_players == 2 {
//                        if gameState.player_turn == playerState.player_num {
//                            return 180
//                        } else {
//                            return 0
//                        }
//                    } else {
//                        return 270
//                    }
//                case 3:
//                    if gameState.num_players == 3 {
//                        return 300
//                    } else {
//                        return 240
//                    }
//                default:
//                    return 0
//            }
//        }
    }
}

#Preview {
    return GeometryReader { geo in
        GameView()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
//            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
