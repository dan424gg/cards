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
    
    var body: some View {
        Text("Turn two!")
            .onAppear(perform: {
                cardsDragged = []
                Task {
                    await firebaseHelper.updatePlayer(newState: ["is_ready": false])
                }
            })
    }
}

#Preview {
    TurnTwoView(cardsDragged: .constant([0]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
