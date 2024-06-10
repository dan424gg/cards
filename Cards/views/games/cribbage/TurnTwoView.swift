//
//  TurnTwoView.swift
//  Cards
//
//  Created by Daniel Wells on 11/3/23.
//

import SwiftUI
import Combine


struct TurnTwoView: View {
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    @Environment(\.namespace) var namespace
    @EnvironmentObject var gameHelper: GameHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var pointsCallOut: [String] = []
    @State private var showAllCards: Bool = false
    @State var timer: Timer?
    @State var displayTimedTextContainer: Bool = false
    @State var points: Int = -1
    @State var color: Color = .purple
    
    
    var otherPlayer: Bool = false
    var otherPlayerPointCallOut: [String] = []
    var otherPlayerTeamNumber: Int = -1
    
    var body: some View {
        VStack(spacing: 6 * (specs.maxY / 852)) {
            ZStack {
                HStack {
                    if let selectedCard = cardsDragged.last {
                        CardView(cardItem: CardItem(id: selectedCard), cardIsDisabled: .constant(false), backside: .constant(false), scale: Double(specs.maxY / 852))
                            .onTapGesture {
                                handleCardTapGesture(selectedCard)
                            }
                            .frame(width: 60 * Double(specs.maxY / 852), height: 100 * Double(specs.maxY / 852))
                    } else {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 60 * Double(specs.maxY / 852), height: 100 * Double(specs.maxY / 852))
                    }
                    
                    VStack(spacing: 6 * (specs.maxY / 852)) {
                        CText("\(gameHelper.gameState?.running_sum ?? 14)", size: 20)
                        
                        CustomButton(name: "GO", submitFunction: handleGoButton, size: Int(specs.maxY / 53.25))
                            .disabled(notPlayersTurn())
                        
                        CustomButton(name: "SUBMIT", submitFunction: {
                            Task {
                                await handleSubmitButton()
                            }
                        }, size: Int(specs.maxY / 53.25), invertColors: true)
                        .disabled(notPlayersTurn())
                    }
                }
                .transition(.offset())
            }
            .overlay {
                TimedTextContainer(display: $displayTimedTextContainer, textArray: .constant(pointsCallOut), visibilityFor: 2.5, color: color)
                    .onAppear {
                        if let team = gameHelper.teams.first(where: { $0.team_num == otherPlayerTeamNumber }) {
                            color = Color("\(team.color)")
                        }
                    }
            }
        }
        .frame(height: 125 * (specs.maxY / 852))
        .onChange(of: cardsDragged, { (old, new) in
            guard !cardsDragged.isEmpty else {
                return
            }

            var callouts: [String] = []
            if !checkForValidityOfPlay(cardsDragged.last ?? -1, runningSum: gameHelper.gameState?.running_sum ?? 32, pointsCallOut: &callouts) {
                pointsCallOut = callouts
                displayTimedTextContainer = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    withAnimation {
                        cardsInHand.append(cardsDragged.removeLast())
                    }
                })
            }
        })
    }
    
    private func handleGoButton() {
        guard gameHelper.gameState != nil else {
            return
        }

        if !checkIfPlayIsPossible() {
            Task {
                if let teamState = gameHelper.teamState {
                    withAnimation(.smooth(duration: 0.5)) {
                        showAllCards = false
                    }
                    var callouts: [String] = []
                    let points = await gameHelper.managePlayTurn(cardInPlay: nil, pointsCallOut: &callouts)
                    
                    await gameHelper.updatePlayer(["callouts": pointsCallOut], arrayAction: .replace)
                    await gameHelper.updateTeam(["points": points + teamState.points])
                    await gameHelper.updateGame(["player_turn": (gameHelper.gameState!.player_turn + 1) % gameHelper.gameState!.num_players])
                    
                    if cardsInHand.isEmpty {
                        Task {
                            do { try await Task.sleep(nanoseconds: 2500000000) } catch { print(error) }
                            
                            if gameHelper.gameState!.num_cards_in_play == (gameHelper.gameState!.num_players * 4) {
                                await gameHelper.updateGame(["player_turn": -1])
                            }
                            
                            await gameHelper.updatePlayer(["is_ready": true])
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                pointsCallOut.append("You have a card you can play!")
            })
        }
    }
    
    private func checkIfPlayIsPossible() -> Bool {
        guard gameHelper.gameState != nil else {
            return false
        }
        
        for card in cardsInHand {
            if checkForValidityOfPlay(card, runningSum: gameHelper.gameState!.running_sum) {
                return true
            }
        }
        
        return false
    }
    
    private func handleCardTapGesture(_ cardId: Int) {
        if !notPlayersTurn() && !cardsDragged.isEmpty {
            withAnimation {
                cardsInHand.append(cardId)
                cardsDragged.removeAll()
            }
        }
    }
    
    private func handleSubmitButton() async {
        var callouts: [String] = []
        
        if checkForValidityOfPlay(cardsDragged.last ?? -1, runningSum: gameHelper.gameState?.running_sum ?? 32, pointsCallOut: &callouts) {
            guard gameHelper.gameState != nil, gameHelper.teamState != nil else {
                return
            }
            
            var callouts: [String] = []
            points = await gameHelper.managePlayTurn(cardInPlay: cardsDragged.last, pointsCallOut: &callouts)
            
            await gameHelper.updatePlayer(["callouts": callouts], arrayAction: .replace)
            await gameHelper.updateTeam(["points": points + gameHelper.teamState!.points])
            await gameHelper.updatePlayer(["cards_dragged": cardsDragged], arrayAction: .append)
            await gameHelper.updateGame(["player_turn": (gameHelper.gameState!.player_turn + 1) % gameHelper.gameState!.num_players])
            
            cardsDragged.removeAll()
            
            if cardsInHand.isEmpty {
                Task {
                    do { try await Task.sleep(nanoseconds: UInt64(callouts.count * 2500000000)) } catch { print(error) }
                    
                    await gameHelper.updatePlayer(["is_ready": true])
                }
            }
        } else {
//            pointsCallOut = callouts
//            displayTimedTextContainer = true
        }
    }
    
    private func notPlayersTurn() -> Bool {
        guard let gameState = gameHelper.gameState, let playerState = gameHelper.playerState else {
            return false
        }
        
        return gameState.player_turn != playerState.player_num
    }
}

#Preview {
    return GeometryReader { geo in
        TurnTwoView(cardsDragged: .constant([0,1,2,3]), cardsInHand: .constant([1]))
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
