//
//  GameView.swift
//  Cards
//
//  Created by Daniel Wells on 11/7/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameHelper: GameHelper
    @EnvironmentObject var specs: DeviceSpecs
    @Namespace var cardsNS
    @State var showSnackbar: Bool = true
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    @State var initial = true
    @State var shown: Bool = false          // for cribbage
    @State var playingGame: Bool = true    // for cribbage

    var body: some View {
        ZStack {
            if (gameHelper.gameState?.turn ?? gameObservable.game.turn) != 6 {
                if playingGame {
                    Group {
                        PlayingTable(gameObservable: gameObservable)
                            .frame(width: specs.maxX * 0.85)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                            .offset(y: -50)
                        
                        PlayerIndicator(gameObservable: gameObservable)
                            .frame(width: specs.maxX * 0.85)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                            .offset(y: -50)
                        
                        NamesAroundTable(gameObservable: gameObservable)
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
                            .offset(y: -50)
                        
                        CribbageBoard()
                            .scaleEffect(0.65 * (specs.maxY / 852))
                            .position(x: specs.maxX / 2, y: specs.maxY * 0.36)
                            .offset(y: -50)
                        
                        CardsView(gameObservable: gameObservable)
                            .offset(y: -50)
                        
                        if gameHelper.gameState?.dealer == gameHelper.playerState?.player_num {
                            CribMarker()
                                .position(x: specs.maxX * 0.90, y: specs.maxY * 0.95)
                                .transition(.opacity)
                        }
                        
                        if shown {
                            PointContainer(player: gameHelper.playerState ?? PlayerState.player_one, user: true)
                                .scaleEffect(specs.maxY / 852)
                                .position(x: specs.maxX / 2, y: specs.maxY * 0.71)
                                .transition(.opacity)
                        }
                        
                        GameOutcomeView(outcome: $gameHelper.gameOutcome)
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
        .onChange(of: gameHelper.playerState?.is_ready, {
            guard gameHelper.playerState != nil, gameHelper.gameState != nil, gameHelper.playerState!.is_lead else {
                return
            }
            
            if gameHelper.playersAreReady() {
                Task {
                    if gameHelper.gameState!.turn == 5 {
                        do { try await Task.sleep(nanoseconds: UInt64(1500000000)) } catch { print(error) }
                    }
                    await gameHelper.unreadyAllPlayers()
                    await gameHelper.updateGame(["turn": (gameHelper.gameState!.turn + 1) % 7])
                }
            }
        })
        .onChange(of: gameHelper.players, {
            guard gameHelper.playerState != nil, gameHelper.gameState != nil, gameHelper.playerState!.is_lead else {
                return
            }
            
            if gameHelper.playersAreReady() {
                Task {
                    if gameHelper.gameState!.turn == 5 {
                        do { try await Task.sleep(nanoseconds: UInt64(1500000000)) } catch { print(error) }
                    }
                    await gameHelper.unreadyAllPlayers()
                    await gameHelper.updateGame(["turn": (gameHelper.gameState!.turn + 1) % 7])
                }
            }
        })
        .onChange(of: gameHelper.teamState?.points, {
            guard gameHelper.teamState != nil else {
                return
            }
            
            if gameHelper.teamState!.points >= 120 {
                Task {
                    await gameHelper.updateGame(["who_won": gameHelper.teamState!.team_num])
                }
                
                gameHelper.gameOutcome = .win
            }
        })
        .onChange(of: gameHelper.gameState?.who_won,  {
            guard gameHelper.gameState != nil, gameHelper.teamState != nil else {
                return
            }
            
            if gameHelper.teamState!.team_num == gameHelper.gameState!.who_won {
                gameHelper.gameOutcome = .win
            } else {
                gameHelper.gameOutcome = .lose
            }
        })
        .onChange(of: gameHelper.gameState?.turn, initial: true, {
            guard gameHelper.gameState != nil else {
                return
            }
            
            if gameHelper.gameState!.turn == -1 {
                guard gameHelper.playerState != nil, gameHelper.playerState!.is_lead else {
                    return
                }
                
                Task(priority: .userInitiated) {
                    let randDealer = Int.random(in: 0..<(gameHelper.gameState!.num_players))
                    
                    // determine dealer's team for crib
                    if let teamWithCrib = gameHelper.players.first(where: { $0.player_num == randDealer })?.team_num {
                        await gameHelper.updateGame(["dealer": randDealer, "team_with_crib": teamWithCrib])
                    } else {
                        let teamWithCrib = gameHelper.playerState!.team_num
                        await gameHelper.updateGame(["dealer": randDealer, "team_with_crib": teamWithCrib])
                    }
                    
                    await gameHelper.updateGame(["turn": 0])
                }
            } else if gameHelper.gameState!.turn == 0 {
                withAnimation {
                    playingGame = true
                }
                
                guard gameHelper.playerState!.player_num == gameHelper.gameState!.dealer else {
                    return
                }
                
                Task {
                    await gameHelper.shuffleAndDealCards()
                    await gameHelper.updateGame(["turn": 1])
                }
                
            } else if gameHelper.gameState!.turn == 2 {
                guard gameHelper.gameState != nil, gameHelper.playerState != nil, gameHelper.playerState!.is_lead else {
                    return
                }
                Task {
                    await gameHelper.updateGame(["player_turn": (gameHelper.gameState!.dealer + 1) % gameHelper.gameState!.num_players])
                }
            } else if gameHelper.gameState!.turn == 3 {
                let numPlayers = gameHelper.gameState!.num_players
                
                for i in 0...numPlayers {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i + 1) * 1.5), execute: {
                        if i == numPlayers {
                            Task {
                                await gameHelper.updatePlayer(["is_ready": true])
                            }
                        } else if i == 0 {
                            // UPDATING GAMESTATE LOCALLY
                            gameHelper.gameState!.player_turn = gameHelper.gameState!.dealer
                            if gameHelper.playerState!.player_num == gameHelper.gameState!.player_turn {
                                withAnimation {
                                    shown = true
                                }
                            }
                        } else {
                            // UPDATING GAMESTATE LOCALLY
                            gameHelper.gameState!.player_turn = (gameHelper.gameState!.player_turn + 1) % numPlayers
                            if gameHelper.playerState!.player_num == gameHelper.gameState!.player_turn {
                                withAnimation {
                                    shown = true
                                }
                            }
                        }
                    })
                }
            } else if gameHelper.gameState!.turn == 5 {
                withAnimation {
                    shown = false
                    playingGame = false
                }
            } else if gameHelper.gameState!.turn == 6 {
                guard gameHelper.playerState != nil, gameHelper.playerState!.is_lead else {
                    return
                }
                
                Task {
                    await gameHelper.resetGame()
                    try await Task.sleep(nanoseconds: UInt64(2.0 * Double(NSEC_PER_SEC)))
                    await gameHelper.updateGame(["turn": (gameHelper.gameState!.turn + 1) % 7])
                }
            }
        })
    }
    
    struct PlayingTable: View {
        @EnvironmentObject var gameHelper: GameHelper
        @EnvironmentObject var specs: DeviceSpecs
        @StateObject var gameObservable: GameObservable
        
        var turn: Int {
            if gameHelper.gameState != nil {
                return gameHelper.gameState!.turn
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
                        .stroke(specs.theme.colorWay.primary, lineWidth: 5)
                        .fill(specs.theme.colorWay.background)
//                } else {
//                    Circle()
//                        .stroke(specs.theme.colorWay.white, lineWidth: 3)
//                }
//            }
        }
    }
    
    struct PlayerIndicator: View {
        @EnvironmentObject var gameHelper: GameHelper
        @EnvironmentObject var specs: DeviceSpecs
        @State var initialRotation: Int = 0
        @State var multiplier: Int = 0
        @State var rotation: Double = 90.0
        @State var sortedPlayerNumList: [Int] = []
        @StateObject var gameObservable: GameObservable
        
        var turn: Int {
            if gameHelper.gameState != nil {
                return gameHelper.gameState!.turn
            } else {
                return gameObservable.game.turn
            }
        }
        
        var playerTurn: Int {
            if gameHelper.gameState != nil {
                return gameHelper.gameState!.player_turn
            } else {
                return gameObservable.game.player_turn
            }
        }
        
        var body: some View {
            if turn == 2 && playerTurn != -1 {
                Circle()
                    .trim(from: 0.0, to: 0.09375)
                    .rotation(.degrees(-16.875 + 90.0))
                    .stroke(specs.theme.colorWay.secondary, lineWidth: 5)
                    .rotationEffect(.degrees(Double(rotation)))
                    .transition(.opacity)
                    .onAppear {
                        if gameHelper.gameState != nil {
                            // set multiplier based on number of players
                            multiplier = 360 / gameHelper.gameState!.num_players
                            var players = gameHelper.players
                            players.append(gameHelper.playerState!)
                            players.sort(by: { $0.player_num < $1.player_num })
                            
                            // reorder player list to match playerViews
                            let beforePlayer = players[0..<gameHelper.playerState!.player_num]
                            let afterPlayer = players[gameHelper.playerState!.player_num..<players.count]
                            
                            sortedPlayerNumList = Array(afterPlayer + beforePlayer).map({ $0.player_num })
                            
                            // find index of player's turn
                            if let idx = sortedPlayerNumList.firstIndex(where: { $0 == gameHelper.gameState!.player_turn }) {
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
                        
                        guard gameHelper.playerState != nil else {
                            return
                        }
                        
                        if playerTurn == gameHelper.playerState!.player_num {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    })
            }
        }
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
            .environmentObject(GameHelper())
//            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
