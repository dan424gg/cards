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
    @State var invalid: Bool = true
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
        VStack {
            if otherPlayer {
                ZStack {
                    HStack {
                        if (showAllCards) {
                            horizontalViewOfCards
                        } else {
                            stackedViewOfCards
                                .frame(width: 60 * Double(specs.maxY / 852), height: 100 * Double(specs.maxY / 852))
                        }
                    }
                    .transition(.offset())
                    
                    TimedTextContainer(display: $displayTimedTextContainer, textArray: .constant(otherPlayerPointCallOut), visibilityFor: 2.0, color: color)
                        .onAppear {
                            if let team = gameHelper.teams.first(where: { $0.team_num == otherPlayerTeamNumber }) {
                                color = Color("\(team.color)")
                            }
                        }
                }
                .frame(width: 167 * (specs.maxX / 393), height: 100 * (specs.maxY / 852))
            } else {
                ZStack {
                    HStack {
                        if (showAllCards) {
                            horizontalViewOfCards
                        } else {
                            stackedViewOfCards
                                .frame(width: 60 * Double(specs.maxY / 852), height: 100 * Double(specs.maxY / 852))
                        }
                        
                        VStack(spacing: 8) {
                            CText("\(gameHelper.gameState?.running_sum ?? 14)", size: 20)
                            
                            CustomButton(name: "GO", submitFunction: handleGoButton, size: Int(specs.maxY / 60.85))
                                .disabled(handleDisabledState())
                            
                            CustomButton(name: "SHOW", submitFunction: {
                                if cardsDragged.count > 1 {
                                    withAnimation(.smooth(duration: 0.5)) {
                                        showAllCards.toggle()
                                    }
                                }
                            }, size: Int(specs.maxY / 60.85))
                        }
                    }
                    .transition(.offset())
                    
                    TimedTextContainer(display: $displayTimedTextContainer, textArray: $pointsCallOut, visibilityFor: 2.0, color: color)
                        .onAppear {
                            if let team = gameHelper.teamState {
                                color = Color("\(team.color)")
                            }
                        }
                }
                
                CustomButton(name: "SUBMIT", submitFunction: {
                    Task {
                        await handleSubmitButton()
                    }
                }, size: Int(specs.maxY / 60.85), invertColors: true)
                    .disabled(invalid)
            }
        }
        .frame(height: 140 * (specs.maxY / 852))
        .onChange(of: cardsDragged, { (old, new) in
            guard !cardsDragged.isEmpty else {
                return
            }

            var callouts: [String] = []
            if checkForValidityOfPlay(cardsDragged.last ?? -1, runningSum: gameHelper.gameState?.running_sum ?? 32, pointsCallOut: &callouts) {
                invalid = false
            } else if (cardsDragged.count - (gameHelper.playerState?.cards_dragged.count ?? 0) == 1) {
                pointsCallOut = callouts
                displayTimedTextContainer = true
                invalid = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                    withAnimation {
                        cardsInHand.append(cardsDragged.removeLast())
                    }
                })
            }
        })
    }
    
    var horizontalViewOfCards: some View {
        Group {
            if cardsDragged.count > 3 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(Array(cardsDragged.reversed().enumerated()), id: \.offset) { (index, cardId) in
                            CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), scale: Double(specs.maxY / 852))
                                .matchedGeometryEffect(id: cardId, in: namespace)
                                .zIndex(Double(-index))
                                .onTapGesture {
                                    handleCardTapGesture(cardId)
                                }
                            
                        }
                    }
                    .padding()
                }
                .frame(width: 160, height: 100)
            } else {
                HStack(spacing: 5) {
                    ForEach(Array(cardsDragged.reversed().enumerated()), id: \.offset) { (index, cardId) in
                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), scale: Double(specs.maxY / 852))
                            .matchedGeometryEffect(id: cardId, in: namespace)
                            .zIndex(Double(-index))
                            .onTapGesture {
                                handleCardTapGesture(cardId)
                            }
                        
                    }
                }
            }
        }
    }

    var stackedViewOfCards: some View {
        ZStack {
            ForEach(Array(cardsDragged.reversed().enumerated()), id: \.offset) { (index, cardId) in
                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), scale: Double(specs.maxY / 852))
                    .matchedGeometryEffect(id: cardId, in: namespace)
                    .zIndex(Double(-index))
                    .onTapGesture {
                        handleCardTapGesture(cardId)
                    }
            }
        }
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
                    pointsCallOut = callouts
                    
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
            pointsCallOut.append("You have a card you can play!")
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
    
    private func handleOtherPlayerCardTapGesture() {
        if showAllCards {
            timer?.invalidate()
            timer = nil
            withAnimation(.smooth(duration: 0.5)) {
                showAllCards = false
            }
        } else {
            withAnimation(.smooth(duration: 0.5)) {
                showAllCards = true
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false, block: { _ in
                withAnimation(.smooth(duration: 0.5)) {
                    showAllCards = false
                }
            })
        }
    }
    
    private func handleCardTapGesture(_ cardId: Int) {
        if otherPlayer {
            handleOtherPlayerCardTapGesture()
        } else if (gameHelper.playerState?.cards_dragged.last ?? -1) != cardId {
            withAnimation {
                cardsInHand.append(cardId)
                cardsDragged.removeAll(where: { $0 == cardId })
            }
        }
    }
    
    private func handleSubmitButton() async {
        guard gameHelper.gameState != nil, gameHelper.teamState != nil else {
            return
        }
        
        var callouts: [String] = []
        points = await gameHelper.managePlayTurn(cardInPlay: cardsDragged.last, pointsCallOut: &callouts)
        pointsCallOut = callouts
        
        withAnimation {
            displayTimedTextContainer = true
        }
        
        withAnimation(.smooth(duration: 0.5)) {
            showAllCards = false
        }
        
        invalid = true
        await gameHelper.updatePlayer(["callouts": pointsCallOut], arrayAction: .replace)
        await gameHelper.updateTeam(["points": points + gameHelper.teamState!.points])
        await gameHelper.updatePlayer(["cards_dragged": cardsDragged], arrayAction: .append)
        await gameHelper.updateGame(["player_turn": (gameHelper.gameState!.player_turn + 1) % gameHelper.gameState!.num_players])
        
        if cardsInHand.isEmpty {
            Task {
                do { try await Task.sleep(nanoseconds: UInt64(pointsCallOut.count * 2500000000)) } catch { print(error) }
//
//                if gameHelper.gameState!.num_cards_in_play == (gameHelper.gameState!.num_players * 4) {
//                    await gameHelper.updateGame(["player_turn": -1])
//                }
                
                await gameHelper.updatePlayer(["is_ready": true])
            }
        }
    }
    
    private func handleDisabledState() -> Bool {
        guard let gameState = gameHelper.gameState, let playerState = gameHelper.playerState else {
            return false
        }
        
        return gameState.player_turn != playerState.player_num
    }
}

#Preview {
    return GeometryReader { geo in
        TurnTwoView(cardsDragged: .constant([0,1,2,3]), cardsInHand: .constant([]))
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
