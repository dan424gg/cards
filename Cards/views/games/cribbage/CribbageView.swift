////
////  Cribbage.swift
////  Cards
////
////  Created by Daniel Wells on 10/11/23.
////
//
//import SwiftUI
//
//struct Cribbage: View {    
//    @EnvironmentObject var firebaseHelper: FirebaseHelper
//    @StateObject private var gameObservable = GameObservable(game: GameState.game)
//    @State private var insideTurnChange: Bool = false
//    @Binding var cardsDragged: [Int]
//    @Binding var cardsInHand: [Int]
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                switch(firebaseHelper.gameState?.turn ?? gameObservable.game.turn) {
//                    case 1:
//                        Text("The Deal")
//                            .font(.title3)
//                            .foregroundStyle(.gray.opacity(0.7))
//                        TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
//                    case 2:
//                        TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: .constant([]), otherPlayer: false)
//                    case 3:
////                        Text("Turn Three!")
//                        VStack {
//                            // used for testing preview
//                            Button("increment player turn") {
//                                Task {
//                                    await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.player_turn + 1) % firebaseHelper.gameState!.num_players])
//                                }
//                            }
//                        }
//                        .offset(y: -70)
//                    case 4:
//                        Text("")
//                    default:
//                        Text("Won't get here")
//                            .font(.title3)
//                            .foregroundStyle(.gray.opacity(0.7))
//                }
//            }
//        }
//        .onChange(of: firebaseHelper.players) {
//            if firebaseHelper.playerState!.is_lead && firebaseHelper.playersAreReady() && !insideTurnChange {
//                insideTurnChange.toggle()
//                Task {
//                    if (firebaseHelper.gameState!.turn == 2) {
//                        await firebaseHelper.updateGame(["play_cards": [] as! [Int], "running_sum": 0, "num_go": 0, "player_turn": 0], arrayAction: .replace)
//                    }
//                    
//                    await firebaseHelper.unreadyAllPlayers()
//                    await firebaseHelper.updateGame(["turn": ((firebaseHelper.gameState!.turn % 4) + 1)])
//
//                    insideTurnChange.toggle()
//                }
//            }
//        }
//    }
//}
//
//struct Cribbage_Previews: PreviewProvider {
//    static var previews: some View {
//        Cribbage(cardsDragged: .constant([]), cardsInHand: .constant([]))
//            .environmentObject(FirebaseHelper())
//    }
//}
