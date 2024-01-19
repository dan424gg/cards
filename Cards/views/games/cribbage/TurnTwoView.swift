//
//  TurnTwoView.swift
//  Cards
//
//  Created by Daniel Wells on 11/3/23.
//

import SwiftUI

struct TurnTwoView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [Int]
    @Binding var cardsInHand: [Int]
    
    @State private var dropAreaBorderColor: Color = .clear
    @State private var dropAreaBorderWidth: CGFloat = 1.0
    @State private var pointsCallOut: [String] = []
    
    var body: some View {
        VStack {
            HStack {
                ZStack{
                    if cardsDragged.count == 0 {
                        CardPlaceHolder()
                            .border(dropAreaBorderColor, width: dropAreaBorderWidth)
                        
                    } else {
                        ForEach(cardsDragged, id: \.self) { cardId in
                            CardView(cardItem: CardItem(id: cardId), cardIsDisabled: .constant(true))
                                .offset(x: -Double.random(in: -2.5...2.5), y: -Double.random(in: -5.0...5.0))
                                .rotationEffect(.degrees(Double.random(in: -5.0...5.0)))
                        }
                    }
                }
                .dropDestination(for: CardItem.self) { items, location in
                    Task {
                        let points = await firebaseHelper.checkForPoints(cardInPlay: items.first!.id, pointsCallOut: $pointsCallOut)
                        await firebaseHelper.updateTeam(newState: ["points": firebaseHelper.teamState!.points + points])
                    }
                    cardsDragged.append(items.first!.id)
                    cardsInHand.removeAll(where: { card in
                        card == items.first!.id
                    })
                    return true
                } isTargeted: { inDropArea in
                    dropAreaBorderColor = inDropArea ? .green : .clear
                    dropAreaBorderWidth = inDropArea ? 7.0 : 1.0
                }
                
                VStack {
                    Text("\(firebaseHelper.gameState?.running_sum ?? 14)")
                        .bold()
                    Button("Go") {
                        Task {
                            let points = await firebaseHelper.checkForPoints(cardInPlay: nil, pointsCallOut: $pointsCallOut)
                            await firebaseHelper.updateTeam(newState: ["points": firebaseHelper.teamState!.points + points])
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            TimedTextContainer(textArray: $pointsCallOut, visibilityFor: 2.0)
        }
        .onChange(of: cardsDragged, {
            Task {
                await firebaseHelper.updatePlayer(newState: ["cards_in_hand": cardsDragged], cardAction: .remove)
            }
        })
        .onDisappear {
            Task {
                await firebaseHelper.updatePlayer(newState: ["cards_in_hand": cardsDragged], cardAction: .replace)
            }
        }
    }
}

#Preview {
    TurnTwoView(cardsDragged: .constant([0]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
