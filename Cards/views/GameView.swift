//
//  GameView.swift
//  Cards
//
//  Created by Daniel Wells on 11/7/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State var showSnackbar: Bool = true
    @State var cardsDragged: [Int] = []
    @State var cardsInHand: [Int] = []
    @State var initial = true
    @State var scale: Double = 0.0
        
    var body: some View {
        GeometryReader { geo in
            GameHeader()
            ZStack {
                // "table"
                PlayingTable()
                    .stroke(Color.gray.opacity(0.5))
                    .aspectRatio(1.15, contentMode: .fit)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 1.5 )
                
                NamesAroundTable()
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 1.5 )
                
                CribbageBoard()
                    .scaleEffect(x: 0.9, y: 0.9)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 1.65 )
                
                DeckOfCardsView()
                    .scaleEffect(x: 0.65, y: 0.65)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 1.2)
                
                // game that is being played
                VStack {
                    switch (firebaseHelper.gameState?.game_name ?? "cribbage") {
                        case "cribbage":
                            Cribbage(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 0.85)
                        default:
                            Text("\(firebaseHelper.gameState?.game_name ?? "nothing")")
                    }
                }
                
                if (firebaseHelper.gameState?.turn ?? 3 < 3) {
                    CardInHandArea(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                        .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 0.72)
                        .scaleEffect(x: 2, y: 2)
                        .transition(.move(edge: .bottom))
                }
                
                if firebaseHelper.playerState?.player_num ?? 1 == firebaseHelper.gameState?.dealer ?? 1 {
                    Text("Dealer")
                        .position(x: geo.size.width - 50, y: geo.size.height - 10)
                }
            }
            .overlay(content: {
                if firebaseHelper.gameState?.player_turn ?? 0 == firebaseHelper.playerState?.player_num ?? 1 && firebaseHelper.gameState?.turn == 2 {
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
            .snackbar(isShowing: $firebaseHelper.showError,
                      title: "Not Ready",
                      text: firebaseHelper.error,
                      style: .error,
                      actionText: "dismiss",
                      dismissOnTap: false,
                      dismissAfter: nil,
                      action: { firebaseHelper.showError = false; firebaseHelper.error = "" }
            )
            .snackbar(isShowing: $firebaseHelper.showWarning,
                      title: "Not Ready",
                      text: firebaseHelper.warning,
                      style: .warning,
                      actionText: "dismiss",
                      dismissOnTap: false,
                      dismissAfter: nil,
                      action: { firebaseHelper.showWarning = false; firebaseHelper.warning = "" }
            )
        }
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
    GameView()
        .environmentObject(FirebaseHelper())
}
