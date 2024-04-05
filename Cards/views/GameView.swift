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
    @State var shown: Bool = false                                          // for cribbage

    var body: some View {
        ZStack {
            PlayingTable()
                .stroke(Color.black)
                .frame(height: specs.maxY * 0.4)
                .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
            
            NamesAroundTable()
                .position(x: specs.maxX / 2, y: specs.maxY * 0.4)
            
            CribbageBoard()
                .scaleEffect(x: 0.8, y: 0.8)
                .position(x: specs.maxX / 2, y: specs.maxY * 0.39 )
            
            CardsView()
            
            if shown {
                PointContainer(player: firebaseHelper.playerState ?? PlayerState.player_six, user: true)
                    .position(x: specs.maxX / 2, y: specs.maxY * 0.71)
                    .transition(.opacity)
            }            
            
            GameOutcomeView(outcome: $firebaseHelper.gameOutcome)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                Task {
                    await firebaseHelper.updateGame(["turn": 0])
                }
            })
        }
        .disabled(firebaseHelper.gameOutcome != .undetermined)
        .onChange(of: firebaseHelper.playerState?.is_ready, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil, firebaseHelper.playerState!.is_lead else {
                return
            }
            
            if firebaseHelper.playersAreReady() {
                Task {
                    await firebaseHelper.unreadyAllPlayers()
                    await firebaseHelper.updateGame(["turn": (firebaseHelper.gameState!.turn + 1) % 5])
                }
            }
        })
        .onChange(of: firebaseHelper.players, {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil, firebaseHelper.playerState!.is_lead else {
                return
            }
            
            if firebaseHelper.playersAreReady() {
                Task {
                    await firebaseHelper.unreadyAllPlayers()
                    await firebaseHelper.updateGame(["turn": (firebaseHelper.gameState!.turn + 1) % 5])
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
        .onChange(of: firebaseHelper.gameState?.who_won, {
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
            
            if firebaseHelper.gameState!.turn == 0 {
                shown = false
                
                guard firebaseHelper.playerState!.is_lead else {
                    return
                }
                
                if initial {
                    // pick first dealer randomly
                    let randDealer = Int.random(in: 0..<(firebaseHelper.gameState!.num_players))
                    
                    // determine dealer's team for crib
                    if let teamWithCrib = firebaseHelper.players.first(where: { $0.player_num == randDealer })?.team_num {
                        Task {
                            await firebaseHelper.updateGame(["dealer": randDealer, "team_with_crib": teamWithCrib])
                        }
                        
                        initial = false
                    } else {
                        let teamWithCrib = firebaseHelper.playerState!.team_num
                        
                        Task {
                            await firebaseHelper.updateGame(["dealer": randDealer, "team_with_crib": teamWithCrib])
                        }
                        
                        initial = false
                    }
                } else {
                    // rotate dealer and team with crib
                    Task {
                        await firebaseHelper.updateGame(["dealer": ((firebaseHelper.gameState!.dealer + 1) % firebaseHelper.gameState!.num_players),
                                                         "team_with_crib": (firebaseHelper.gameState!.team_with_crib + 1) % firebaseHelper.gameState!.num_teams])
                    }
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
            }
        })
        .onChange(of: firebaseHelper.gameState?.dealer, {
            if firebaseHelper.playerState?.player_num == firebaseHelper.gameState?.dealer &&
                firebaseHelper.gameState?.turn == 0 {
                Task {
                    await firebaseHelper.shuffleAndDealCards()
                    await firebaseHelper.updateGame(["turn": 1])
                }
            }
        })
    }
}

struct PlayingTable: Shape {
    func path(in rect: CGRect) -> Path {
        let r = rect.height / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: r, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: false)
        return path
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
            .background(Color("OffWhite").opacity(0.1))
        
    }
    .ignoresSafeArea()
}
