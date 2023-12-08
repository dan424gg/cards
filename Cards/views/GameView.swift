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
    @State var cardsDragged: [CardItem] = []
    @State var cardsInHand: [CardItem] = []
        
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
//                    .rotationEffect(.degrees(45))
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 1.65 )
                
                DeckOfCardsView()
                    .scaleEffect(x: 0.65, y: 0.65)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 1.2)
                
                // game that is being played
                VStack {
                    switch (firebaseHelper.gameInfo?.game_name ?? "cribbage") {
                    case "cribbage":
                        Cribbage(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 0.52)
                    default: EmptyView()
                    }
                }
                .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY / 4.75)
            }
            .onChange(of: firebaseHelper.gameInfo?.turn, initial: true, {
                if firebaseHelper.gameInfo?.turn == 1 {
                    // pick dealer
                    
                    Task {
                        await firebaseHelper.shuffleAndDealCards(cardsInHand_binding: $cardsInHand)
                    }
                }
            })
            .snackbar(isShowing: $firebaseHelper.showWarning, title: "Not Ready", text: firebaseHelper.error, style: .error, actionText: "dismiss", dismissOnTap: false, dismissAfter: nil, action: { firebaseHelper.showWarning = false })
            .snackbar(isShowing: $firebaseHelper.showError, title: "Not Ready", text: firebaseHelper.warning, style: .warning, actionText: "dismiss", dismissOnTap: false, dismissAfter: nil, action: { firebaseHelper.showError = false })
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
