import SwiftUI
import Foundation
import UniformTypeIdentifiers

func convertToCardItem(_ id: Int) -> CardItem {
    return CardItem(id: id)
}

func convertToCardItem(_ ids: [Int]) -> [CardItem] {
    return ids.map {
        CardItem(id: $0)
    }
}

func convertToInt(_ cardItem: CardItem) -> Int {
    return cardItem.id
}

func convertToInt(_ cardItems: [CardItem]) -> [Int] {
    return cardItems.map {
        $0.id
    }
}

struct CardItem: Codable, Identifiable, Transferable {
    public init(id: Int) {
        self.id = id
    }
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: CardItem.self, contentType: .card)
    }
    
    static func < (lhs: CardItem, rhs: CardItem) -> Bool {
        return (lhs.id % 13) < (rhs.id % 13)
    }
    
    static func > (lhs: CardItem, rhs: CardItem) -> Bool {
        return (lhs.id % 13) > (rhs.id % 13)
    }
    
    static func <= (lhs: CardItem, rhs: CardItem) -> Bool {
        return (lhs.id % 13) <= (rhs.id % 13)
    }
    
    static func >= (lhs: CardItem, rhs: CardItem) -> Bool {
        return (lhs.id % 13) >= (rhs.id % 13)
    }
    
    static func == (lhs: CardItem, rhs: CardItem) -> Bool {
        return (lhs.id % 13) == (rhs.id % 13)
    }
    
    var id: Int
    var card: Card {
        return Card(id: id)
    }
}

struct Card: Codable {
    var value: String
    var suit: String
    
    init(id: Int) {
        let suitIndex = id / 13
        let valueIndex = id % 13
        
        switch suitIndex {
            case 0: suit = "spade"
            case 1: suit = "heart"
            case 2: suit = "diamond"
            case 3: suit = "club"
            default: suit = ""
        }
        
        switch valueIndex {
            case 0: value = "A"
            case 10: value = "J"
            case 11: value = "Q"
            case 12: value = "K"
            default: value = "\(valueIndex + 1)"
        }
    }
    
    var pointValue: Int {
        switch value {
            case "A": return 1
            case "J", "Q", "K": return 10
            default: return Int(value) ?? 0
        }
    }
}


