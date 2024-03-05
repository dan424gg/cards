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
    @State var showSnackbar: Bool = true
    @State var cardsDragged: [Int] = []
    @State var cardsInHand: [Int] = []
    @State var initial = true
    @State var scale: Double = 0.0
        
    var body: some View {
            ZStack {
                GameHeader()
                
                // "table"
                PlayingTable()
                    .stroke(Color.gray.opacity(0.5))
                    .aspectRatio(1.15, contentMode: .fit)
                    .position(x: specs.maxX / 2, y: specs.maxY / 2 / 1.5 )
                
                NamesAroundTable()
                    .position(x: specs.maxX / 2, y: specs.maxY / 2 / 1.5 )
                
                CribbageBoard()
                    .scaleEffect(x: 0.8, y: 0.8)
                    .position(x: specs.maxX / 2, y: specs.maxY / 2 / 1.65 )
                
                DeckOfCardsView()
                    .scaleEffect(x: 0.65, y: 0.65)
                    .position(x: specs.maxX / 2, y: specs.maxY / 2 / 1.2)
                
                // game that is being played
                VStack {
                    switch (firebaseHelper.gameState?.game_name ?? "cribbage") {
                        case "cribbage":
                            Cribbage(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                                .frame(width: specs.maxX, height: specs.maxY)
                                .position(x: specs.maxX / 2, y: specs.maxY / 2 / 0.85)
                        default:
                            Text("\(firebaseHelper.gameState?.game_name ?? "nothing")")
                    }
                }
                
                if (firebaseHelper.gameState?.turn ?? 2 < 3) {
                    CardInHandArea(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                        .position(x: specs.maxX / 2, y: specs.maxY / 2)
                        .scaleEffect(x: 2, y: 2)
                        .transition(.move(edge: .bottom))
                }
                
                if firebaseHelper.playerState?.player_num ?? 1 == firebaseHelper.gameState?.dealer ?? 1 {
                    Text("Dealer")
                        .position(x: specs.maxX - 50, y: specs.maxY - 10)
                }
                
                GameOutcomeView(outcome: $firebaseHelper.gameOutcome)
            }
        
        .border(.red)
        .disabled(firebaseHelper.gameOutcome != .undetermined)
        .overlay(content: {
            if (firebaseHelper.gameState == nil || firebaseHelper.playerState == nil) {
                EmptyView()
            } else {
                if firebaseHelper.gameState!.player_turn == firebaseHelper.playerState!.player_num && firebaseHelper.gameState!.turn == 2 && firebaseHelper.gameState!.is_playing {
                    RoundedRectangle(cornerRadius: 57.0, style: .continuous)
                        .stroke(Color("greenForPlayerPlaying"), lineWidth: 25.0)
                        .opacity(scale)
                        .ignoresSafeArea()
                        .onAppear {
                            let baseAnimation = Animation.easeInOut(duration: 2.0)
                            let repeated = baseAnimation.repeatForever(autoreverses: true)
                            
                            withAnimation(repeated) {
                                scale = 0.8
                            }
                        }
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
            } else {
                firebaseHelper.gameOutcome = .lose
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
            guard firebaseHelper.gameState != nil, firebaseHelper.playerState != nil else {
                return
            }
            
            if firebaseHelper.playerState!.is_lead && firebaseHelper.gameState!.turn == 1 {
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
        .onChange(of: firebaseHelper.gameState?.dealer, initial: true, {
            if firebaseHelper.playerState?.player_num == firebaseHelper.gameState?.dealer &&
                firebaseHelper.gameState?.turn == 1 {
                Task {
                    await firebaseHelper.shuffleAndDealCards()
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
        path.addArc(center: center, radius: r,
                        startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: false)
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
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(Color("OffWhite").opacity(0.1))
        
    }
    .ignoresSafeArea()
}
