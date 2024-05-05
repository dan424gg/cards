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
    @EnvironmentObject var firebaseHelper: FirebaseHelper
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
                                .frame(width: 60, height: 100)
                        }
                    }
                    .transition(.offset())
                    
                    TimedTextContainer(display: $displayTimedTextContainer, textArray: .constant(otherPlayerPointCallOut), visibilityFor: 2.0, color: color)
                        .onAppear {
                            if let team = firebaseHelper.teams.first(where: { $0.team_num == otherPlayerTeamNumber }) {
                                color = Color("\(team.color)")
                            }
                        }
                }
                .frame(width: 167, height: 100)
            } else {
                ZStack {
                    HStack {
                        if (showAllCards) {
                            horizontalViewOfCards
                        } else {
                            stackedViewOfCards
                                .frame(width: 60, height: 100)
                        }
                        
                        VStack {
                            Text("\(firebaseHelper.gameState?.running_sum ?? 14)")
                                .foregroundStyle(specs.theme.colorWay.textColor)
                                .font(.custom("LuckiestGuy-Regular", size: 16))
                                .baselineOffset(-1.6)
                            
                            Button {
                                handleGoButton()
                            } label: {
                                Text("GO")
                                    .font(.custom("LuckiestGuy-Regular", size: 16))
                                    .baselineOffset(-5)
                            }
                            .frame(width: 68, height: 32)
                            .background {
                                VisualEffectView(effect: UIBlurEffect(style: .prominent))
                                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            }
                            .disabled(handleDisabledState())
                            
                            Button {
                                withAnimation(.smooth(duration: 0.5)) {
                                    showAllCards.toggle()
                                }
                            } label: {
                                Text("Show")
                                    .font(.custom("LuckiestGuy-Regular", size: 16))
                                    .baselineOffset(-5)
                            }
                            .frame(width: 68, height: 32)
                            .background {
                                VisualEffectView(effect: UIBlurEffect(style: .prominent))
                                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                            }
                        }
                    }
                    .transition(.offset())
                    
                    TimedTextContainer(display: $displayTimedTextContainer, textArray: $pointsCallOut, visibilityFor: 2.0, color: color)
                        .onAppear {
                            if let team = firebaseHelper.teamState {
                                color = Color("\(team.color)")
                            }
                        }
                }
                
                Button {
                    Task {
                        await handleSubmitButton()
                    }
                } label: {
                    Text("Submit")
                        .foregroundStyle(invalid ? .red : .green)
                        .font(.custom("LuckiestGuy-Regular", size: 16))
                        .baselineOffset(-5)
                }
                .frame(width: 80, height: 32)
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .prominent))
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }
                .disabled(invalid)
            }
        }
        .frame(height: 140)
        .onAppear {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil, firebaseHelper.playerState!.is_lead else {
                return
            }
            
//            Task {
//                await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.dealer + 1) % firebaseHelper.gameState!.num_players])
//            }
        }
        .onChange(of: cardsDragged, { (old, new) in
            guard !cardsDragged.isEmpty else {
                return
            }

            var callouts: [String] = []
            if checkForValidityOfPlay(cardsDragged.last ?? -1, runningSum: firebaseHelper.gameState?.running_sum ?? 32, pointsCallOut: &callouts) {
                invalid = false
            } else if (cardsDragged.count - (firebaseHelper.playerState?.cards_dragged.count ?? 0) == 1) {
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
                            CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), naturalOffset: true)
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
                        CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), naturalOffset: true)
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
                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), backside: .constant(false), naturalOffset: true)
                    .matchedGeometryEffect(id: cardId, in: namespace)
                    .zIndex(Double(-index))
                    .onTapGesture {
                        handleCardTapGesture(cardId)
                    }
            }
        }
    }
    
    private func handleGoButton() {
        guard firebaseHelper.gameState != nil else {
            return
        }

        if !checkIfPlayIsPossible() {
            Task {
                if let teamState = firebaseHelper.teamState {
                    withAnimation(.smooth(duration: 0.5)) {
                        showAllCards = false
                    }
                    var callouts: [String] = []
                    let points = await firebaseHelper.managePlayTurn(cardInPlay: nil, pointsCallOut: &callouts)
                    pointsCallOut = callouts
                    
                    await firebaseHelper.updatePlayer(["callouts": pointsCallOut], arrayAction: .replace)
                    await firebaseHelper.updateTeam(["points": points + teamState.points])
                    await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.player_turn + 1) % firebaseHelper.gameState!.num_players])
                    
                    if cardsInHand.isEmpty {
                        Task {
                            do { try await Task.sleep(nanoseconds: 2500000000) } catch { print(error) }
                            
                            if firebaseHelper.gameState!.num_cards_in_play == (firebaseHelper.gameState!.num_players * 4) {
                                await firebaseHelper.updateGame(["player_turn": -1])
                            }
                            
                            await firebaseHelper.updatePlayer(["is_ready": true])
                        }
                    }
                }
            }
        } else {
            pointsCallOut.append("You have a card you can play!")
        }
    }
    
    private func checkIfPlayIsPossible() -> Bool {
        guard firebaseHelper.gameState != nil else {
            return false
        }
        
        for card in cardsInHand {
            if checkForValidityOfPlay(card, runningSum: firebaseHelper.gameState!.running_sum) {
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
        } else if (firebaseHelper.playerState?.cards_dragged.last ?? -1) != cardId {
            withAnimation {
                cardsInHand.append(cardId)
                cardsDragged.removeAll(where: { $0 == cardId })
            }
        }
    }
    
    private func handleSubmitButton() async {
        guard firebaseHelper.gameState != nil, firebaseHelper.teamState != nil else {
            return
        }
        
        var callouts: [String] = []
        points = await firebaseHelper.managePlayTurn(cardInPlay: cardsDragged.last, pointsCallOut: &callouts)
        pointsCallOut = callouts
        
        withAnimation {
            displayTimedTextContainer = true
        }
        
        withAnimation(.smooth(duration: 0.5)) {
            showAllCards = false
        }
        
        invalid = true
        await firebaseHelper.updatePlayer(["callouts": pointsCallOut], arrayAction: .replace)
        await firebaseHelper.updateTeam(["points": points + firebaseHelper.teamState!.points])
        await firebaseHelper.updatePlayer(["cards_dragged": cardsDragged], arrayAction: .append)
        await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.player_turn + 1) % firebaseHelper.gameState!.num_players])
        
        if cardsInHand.isEmpty {
            Task {
                do { try await Task.sleep(nanoseconds: UInt64(pointsCallOut.count * 2500000000)) } catch { print(error) }
//
//                if firebaseHelper.gameState!.num_cards_in_play == (firebaseHelper.gameState!.num_players * 4) {
//                    await firebaseHelper.updateGame(["player_turn": -1])
//                }
                
                await firebaseHelper.updatePlayer(["is_ready": true])
            }
        }
    }
    
    private func handleDisabledState() -> Bool {
        guard let gameState = firebaseHelper.gameState, let playerState = firebaseHelper.playerState else {
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
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
    .ignoresSafeArea()
}
