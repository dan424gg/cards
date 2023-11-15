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
        HStack (spacing: 20) {
            VStack {
                Text("Points")
                Text("\(firebaseHelper.gameInfo?.count_points ?? 11)")
            }
            
            if cardsDragged.count > 0 {
                CardView(cardItem: cardsDragged[0]/*, isDisabled: .constant(false)*/)
            } else {
                CardPlaceHolder()
                    .border(dropAreaBorderColor, width: dropAreaBorderWidth)
                    .dropDestination(for: CardItem.self) { items, location in
//                        if !cardsDragged.contains(items.first!) {
//                            cardsDragged.append(items.first!)
//                            cardsInHand.removeAll(where: { card in
//                                card == items.first!
//                            })
//                        }
                        return true
                    } isTargeted: { inDropArea in
                        dropAreaBorderColor = inDropArea ? .green : .clear
                        dropAreaBorderWidth = inDropArea ? 7.0 : 1.0
                    }
            }
        }
    }
}

#Preview {
    TurnTwoView(cardsDragged: .constant([CardItem(id: 0, value: "A", suit: "H")]), cardsInHand: .constant([]))
        .environmentObject(FirebaseHelper())
}
