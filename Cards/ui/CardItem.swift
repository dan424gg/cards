//
//  CardItem.swift
//  Cards
//
//  Created by Daniel Wells on 10/24/23.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers


struct CardItem: Hashable, Codable, Identifiable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: CardItem.self, contentType: .card)
    }
    
    var id: Int
    var card: String
    
    static var sampleCards: [CardItem] {
        [
            CardItem(id: 0, card: "SA"),
            CardItem(id: 1, card: "HA"),
            CardItem(id: 2, card: "CA"),
            CardItem(id: 3, card: "DA")
        ]
    }
}

extension UTType {
    static var card = UTType(exportedAs: "dan424gg.Cards.CardItems")
}

class Card: ObservableObject {
    @Published var items = [CardItem]()
     
    init() {
        items.append(contentsOf: CardItem.sampleCards)
    }
}
