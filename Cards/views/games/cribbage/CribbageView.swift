//
//  Cribbage.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI

struct Cribbage: View {    
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject private var gameObservable = GameObservable(game: GameState.game)
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    
    var body: some View {
        VStack {
            switch(firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
                case 1:
                    Text("The Deal")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                    TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
                case 2:
                    TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand, otherPlayer: false)
                case 3:
                    Text("The Show")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
                case 4:
                    Text("The Crib")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))

                default:
                    Text("Won't get here")
                        .font(.title3)
                        .foregroundStyle(.gray.opacity(0.7))
            }
            
            // used for testing preview
//            Button("increment team points") {
//                Task {
//                    await firebaseHelper.updateTeam(newState: ["points": firebaseHelper.teamState!.points + 7])
//                }
//                if firebaseHelper.gameState == nil {
//                    gameObservable.game.turn = (gameObservable.game.turn % 4) + 1
//                    print(gameObservable.game.turn)
//                } else {
//                    Task {
//                        await firebaseHelper.updateGame(newState: ["turn": ((firebaseHelper.gameState?.turn ?? 0) % 4) + 1])
//                    }
//                }
//            }
        }
        .onChange(of: firebaseHelper.players) {
            if firebaseHelper.playerState!.is_lead && firebaseHelper.playersAreReady() {
                Task {
                    if (firebaseHelper.gameState!.turn == 2) {
                        await firebaseHelper.updateGame(newState: ["play_cards": [] as! [Int]], action: .replace)
                    }
                    await firebaseHelper.unreadyAllPlayers()
//                    try await Task.sleep(nanoseconds: UInt64(2.0 * Double(NSEC_PER_SEC)))
                    await firebaseHelper.updateGame(newState: ["turn": firebaseHelper.gameState!.turn + 1])
                }
            }
        }
    }
}

struct Cribbage_Previews: PreviewProvider {
    static var previews: some View {
        Cribbage(cardsDragged: .constant([]), cardsInHand: .constant([]))
            .environmentObject(FirebaseHelper())
    }
}
