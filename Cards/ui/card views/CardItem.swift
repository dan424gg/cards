//
//  CardItem.swift
//  Cards
//
//  Created by Daniel Wells on 10/24/23.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers


struct CardItem: Codable, Identifiable, Transferable {
    static func == (lhs: CardItem, rhs: CardItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    public init(id: Int) {
        self.id = id
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: CardItem.self, contentType: .card)
    }
    
    var id: Int
    
    private var cards: [Int : Card] = [
        // Spades
        0 : Card(value: "A", suit: "spade"),
        1 : Card(value: "2", suit: "spade"),
        2 : Card(value: "3", suit: "spade"),
        3 : Card(value: "4", suit: "spade"),
        4 : Card(value: "5", suit: "spade"),
        5 : Card(value: "6", suit: "spade"),
        6 : Card(value: "7", suit: "spade"),
        7 : Card(value: "8", suit: "spade"),
        8 : Card(value: "9", suit: "spade"),
        9 : Card(value: "10", suit: "spade"),
        10 : Card(value: "J", suit: "spade"),
        11 : Card(value: "Q", suit: "spade"),
        12 : Card(value: "K", suit: "spade"),
        
        // Hearts
        13 : Card(value: "A", suit: "heart"),
        14 : Card(value: "2", suit: "heart"),
        15 : Card(value: "3", suit: "heart"),
        16 : Card(value: "4", suit: "heart"),
        17 : Card(value: "5", suit: "heart"),
        18 : Card(value: "6", suit: "heart"),
        19 : Card(value: "7", suit: "heart"),
        20 : Card(value: "8", suit: "heart"),
        21 : Card(value: "9", suit: "heart"),
        22 : Card(value: "10", suit: "heart"),
        23 : Card(value: "J", suit: "heart"),
        24 : Card(value: "Q", suit: "heart"),
        25 : Card(value: "K", suit: "heart"),
        
        // Diamonds
        26 : Card(value: "A", suit: "diamond"),
        27 : Card(value: "2", suit: "diamond"),
        28 : Card(value: "3", suit: "diamond"),
        29 : Card(value: "4", suit: "diamond"),
        30 : Card(value: "5", suit: "diamond"),
        31 : Card(value: "6", suit: "diamond"),
        32 : Card(value: "7", suit: "diamond"),
        33 : Card(value: "8", suit: "diamond"),
        34 : Card(value: "9", suit: "diamond"),
        35 : Card(value: "10", suit: "diamond"),
        36 : Card(value: "J", suit: "diamond"),
        37 : Card(value: "Q", suit: "diamond"),
        38 : Card(value: "K", suit: "diamond"),
        
        // Clubs
        39 : Card(value: "A", suit: "club"),
        40 : Card(value: "2", suit: "club"),
        41 : Card(value: "3", suit: "club"),
        42 : Card(value: "4", suit: "club"),
        43 : Card(value: "5", suit: "club"),
        44 : Card(value: "6", suit: "club"),
        45 : Card(value: "7", suit: "club"),
        46 : Card(value: "8", suit: "club"),
        47 : Card(value: "9", suit: "club"),
        48 : Card(value: "10", suit: "club"),
        49 : Card(value: "J", suit: "club"),
        50 : Card(value: "Q", suit: "club"),
        51 : Card(value: "K", suit: "club"),
    ]
    
    func getCard() -> Card {
        return cards[id]!
    }
    
    enum CodingKeys: CodingKey {
        case id
    }
}

struct Card: Codable {
    var value: String
    var suit: String
    var point_value: Int {
        switch (value) {
        case "A": 1
        case "J": 10
        case "Q": 10
        case "K": 10
        default: Int(value)!
        }
    }
}

extension UTType {
    static var card = UTType(exportedAs: "dan424gg.Cards.CardItems")
}
