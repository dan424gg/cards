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
//    @Environment(GameHelper.self) private var gameHelper
//    @StateObject private var gameObservable = GameObservable(game: GameState.game)
//    @State private var insideTurnChange: Bool = false
//    @Binding var cardsDragged: [Int]
//    @Binding var cardsInHand: [Int]
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                switch(gameHelper.gameState?.turn ?? gameObservable.game.turn) {
//                    case 1:
//                        CText("The Deal")
//                            .font(.title3)
//                            .foregroundStyle(.gray.opacity(0.7))
//                        TurnOneView(cardsDragged: $cardsDragged, cardsInHand: $cardsInHand)
//                    case 2:
//                        TurnTwoView(cardsDragged: $cardsDragged, cardsInHand: .constant([]), otherPlayer: false)
//                    case 3:
////                        CText("Turn Three!")
//                        VStack {
//                            // used for testing preview
//                            Button("increment player turn") {
//                                Task {
//                                    await gameHelper.updateGame(["player_turn": (gameHelper.gameState!.player_turn + 1) % gameHelper.gameState!.num_players])
//                                }
//                            }
//                        }
//                        .offset(y: -70)
//                    case 4:
//                        CText("")
//                    default:
//                        CText("Won't get here")
//                            .font(.title3)
//                            .foregroundStyle(.gray.opacity(0.7))
//                }
//            }
//        }
//        .onChange(of: gameHelper.players) {
//            if gameHelper.playerState!.is_lead && gameHelper.playersAreReady() && !insideTurnChange {
//                insideTurnChange.toggle()
//                Task {
//                    if (gameHelper.gameState!.turn == 2) {
//                        await gameHelper.updateGame(["play_cards": [] as! [Int], "running_sum": 0, "num_go": 0, "player_turn": 0], arrayAction: .replace)
//                    }
//                    
//                    await gameHelper.unreadyAllPlayers()
//                    await gameHelper.updateGame(["turn": ((gameHelper.gameState!.turn % 4) + 1)])
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
//            .environment(GameHelper())
//    }
//}
