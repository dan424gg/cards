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
