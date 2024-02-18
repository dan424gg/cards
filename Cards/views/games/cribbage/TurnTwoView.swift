//
//  TurnTwoView.swift
//  Cards
//
//  Created by Daniel Wells on 11/3/23.
//

import SwiftUI
import Combine


struct TurnTwoView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
        
    @State private var dropAreaBorderColor: Color = .clear
    @State private var dropAreaBorderWidth: CGFloat = 1.0
    @State private var pointsCallOut: [String] = []
    @State private var showAllCards: Bool = false
    @State var timer: Timer?
    
    var otherPlayer: Bool
    
    var body: some View {
        VStack(spacing: 33) {
            if (!otherPlayer) {
                Text("The Play")
                    .font(.title3)
                    .foregroundStyle(.gray)
            }
            
            ZStack {
                VStack {
                    HStack {
                        if cardsDragged.isEmpty {
                            CardPlaceHolder()
                                .border(dropAreaBorderColor, width: dropAreaBorderWidth)
                        } else {
                            ForEach(cardsDragged.reversed(), id: \.self) { cardId in
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), naturalOffset: true)
                                    .disabled(true)
                            }
                        }
                    }
                    .dropDestination(for: CardItem.self, action: handleDropAction, isTargeted: handleIsTargeted)
                    
                    if !otherPlayer {
                        HStack {
                            Text("\(firebaseHelper.gameState?.running_sum ?? 14)")
                                .bold()
                            Button("Go", action: handleGoButton)
                                .buttonStyle(.bordered)
                        }
                    }
                }
                .frame(width: 250, height: 75)
                .opacity(showAllCards ? 1.0 : 0.0)
                .disabled(handleDisabledState())

                HStack {
                    ZStack {
                        if cardsDragged.isEmpty {
                            CardPlaceHolder()
                                .border(dropAreaBorderColor, width: dropAreaBorderWidth)
                        } else {
                            ForEach(cardsDragged, id: \.self) { cardId in
                                CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true), naturalOffset: true)
                                    .disabled(true)
                            }
                        }
                    }
                    .dropDestination(for: CardItem.self, action: handleDropAction, isTargeted: handleIsTargeted)
                    
                    if !otherPlayer {
                        VStack {
                            Text("\(firebaseHelper.gameState?.running_sum ?? 14)")
                                .bold()
                            Button("Go", action: handleGoButton)
                                .buttonStyle(.bordered)
                        }
                    }
                }
                .frame(width: 250, height: 75)
                .opacity(showAllCards ? 0.0 : 1.0)
                .disabled(handleDisabledState())
            }
            TimedTextContainer(textArray: $pointsCallOut, visibilityFor: 2.0)
        }
        .onTapGesture {
            if showAllCards {
                timer?.invalidate()
                timer = nil
                withAnimation {
                    showAllCards = false
                }
            } else {
                withAnimation {
                    showAllCards = true
                }
                timer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false, block: { _ in
                    withAnimation {
                        showAllCards = false
                    }
                })
            }
        }
        .onAppear {
            guard firebaseHelper.playerState != nil, firebaseHelper.gameState != nil, firebaseHelper.playerState!.is_lead else {
                return
            }
            
            Task {
                await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.dealer + 1) % firebaseHelper.gameState!.num_players])
            }
        }
        .if(!otherPlayer) { view in
            view
                .onChange(of: firebaseHelper.playerState?.cards_in_hand, {
                    handleCardsInHandChange()
                })
                .onChange(of: cardsDragged, {
                    handleCardsDraggedChange()
                })
                .onDisappear(perform: handleOnDisappear)
        }
    }
    
    private func handleCardsInHandChange() {
        guard let playerState = firebaseHelper.playerState else {
            return
        }
        
        if playerState.cards_in_hand.isEmpty {
            Task {
                await firebaseHelper.updatePlayer(["is_ready": true])
            }
        }
    }
    
    private func handleCardsDraggedChange() {
        guard firebaseHelper.gameState != nil else {
            return
        }
        
        Task {
            await firebaseHelper.updatePlayer(["cards_in_hand": cardsDragged], arrayAction: .remove)
            await firebaseHelper.updatePlayer(["cards_dragged": cardsDragged], arrayAction: .replace)
        }
    }
    
    private func handleOnDisappear() {
        Task {
            await firebaseHelper.updatePlayer(["cards_in_hand": cardsDragged], arrayAction: .replace)
            cardsDragged = []
            await firebaseHelper.updatePlayer(["cards_dragged": cardsDragged], arrayAction: .replace)
        }
    }
    
    private func handleDropAction(_ items: [CardItem], _ location: CGPoint) -> Bool {
        guard let gameState = firebaseHelper.gameState, let playerState = firebaseHelper.playerState, let teamState = firebaseHelper.teamState else {
            return false
        }
        
        if (gameState.player_turn == playerState.player_num) {
            Task {
                var callouts: [String] = []
                let points = await firebaseHelper.managePlayTurn(cardInPlay: items.first!.id, pointsCallOut: &callouts)
                pointsCallOut = callouts
                
                if (points != -1) {                    
                    await firebaseHelper.updateTeam(["points": points + teamState.points])
                    await firebaseHelper.updateGame(["player_turn": (gameState.player_turn + 1) % gameState.num_players])
     
                    cardsInHand.removeAll { card in
                        card == items.first!.id
                    }
                    cardsDragged.append(items.first!.id)
                    
                    return true
                } else {
                    return false
                }
            }
        }
        return false
    }
    
    private func handleIsTargeted(_ inDropArea: Bool) {
        guard let gameState = firebaseHelper.gameState, let playerState = firebaseHelper.playerState else {
            return
        }
        
        if gameState.player_turn == playerState.player_num {
            dropAreaBorderColor = inDropArea ? .green : .clear
            dropAreaBorderWidth = inDropArea ? 7.0 : 1.0
        }
    }
    
    private func handleGoButton() {
        if !firebaseHelper.checkIfPlayIsPossible() {
            Task {
                if let teamState = firebaseHelper.teamState {
                    var callouts: [String] = []
                    let points = await firebaseHelper.managePlayTurn(cardInPlay: nil, pointsCallOut: &callouts)
                    pointsCallOut = callouts
                    
                    await firebaseHelper.updateTeam(["points": points + teamState.points])
                    await firebaseHelper.updateGame(["player_turn": (firebaseHelper.gameState!.player_turn + 1) % firebaseHelper.gameState!.num_players])
                }
            }
        } else {
            pointsCallOut.append("You have a card you can play!")
        }
    }
    
    private func handleDisabledState() -> Bool {
        guard let gameState = firebaseHelper.gameState, let playerState = firebaseHelper.playerState else {
            return false
        }
        
        return gameState.player_turn != playerState.player_num
    }
}

struct TurnTwoView_Previews: PreviewProvider {
    static var previews: some View {
        TurnTwoView(cardsDragged: .constant([0,1,2,3,4]), cardsInHand: .constant([]), otherPlayer: false)
            .environmentObject(FirebaseHelper())
    }
}
