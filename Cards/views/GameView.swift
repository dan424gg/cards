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
    @State var shown: Bool = false            // for cribbage
    private let timer: Timer? = nil           // for cribbage
    
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
            
            if (((firebaseHelper.gameState?.turn ?? gameObservable.game.turn) >= 3) 
                && ((firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn) == (firebaseHelper.playerState?.player_num ?? PlayerState.player_six.player_num)))
                || shown {
                PointContainer(player: .constant(firebaseHelper.playerState ?? PlayerState.player_six), user: true)
                    .position(x: specs.maxX / 2, y: specs.maxY * 0.71)
                    .transition(.scale)
                    .onAppear {
                        shown = true
                    }
            }            
            
            GameOutcomeView(outcome: $firebaseHelper.gameOutcome)
        }
        .animation(.default, value: (firebaseHelper.gameState?.player_turn ?? gameObservable.game.player_turn))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
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
            guard firebaseHelper.gameState != nil, firebaseHelper.playerState != nil, firebaseHelper.playerState!.is_lead else {
                return
            }
            
            if firebaseHelper.gameState!.turn == 0 {
                if initial {
                    // pick first dealer randomly
                    let randDealer = Int.random(in: 0..<(firebaseHelper.gameState!.num_players))
                    
                    Task {
                        await firebaseHelper.updateGame(["dealer": randDealer])
                    }
                    
                    initial = false
                } else {
                    // rotate dealer
                    Task {
                        await firebaseHelper.updateGame(["dealer": ((firebaseHelper.gameState!.dealer + 1) % firebaseHelper.gameState!.num_players)])
                    }
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
