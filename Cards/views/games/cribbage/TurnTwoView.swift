//
//  TurnTwoView.swift
//  Cards
//
//  Created by Daniel Wells on 11/3/23.
//

import SwiftUI

struct TurnTwoView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var cardsDragged: [CardItem]
    @Binding var cardsInHand: [CardItem]
    
    @State private var dropAreaBorderColor: Color = .clear
    @State private var dropAreaBorderWidth: CGFloat = 1.0
    
    var body: some View {
        Text("Turn two!")
    }
}

#Preview {
    TurnTwoView(cardsDragged: .constant([CardItem(id: 0, value: "A", suit: "H")]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
