//
//  Node.swift
//  Cards
//
//  Created by Daniel Wells on 9/3/24.
//

import Foundation

class Node {
    var points: Int
    var numVisits: Int
    var actionCard: CardItem
    
    var parent: Node?
    var children: [Node]
    
    var rolloutGS: RolloutGameState
    
    init(points: Int, numVisits: Int, actionCard: CardItem, parent: Node?, children: [Node], rolloutGS: RolloutGameState) {
        self.points = points
        self.numVisits = numVisits
        self.actionCard = actionCard
        self.parent = parent
        self.children = children
        self.rolloutGS = rolloutGS
    }
    
    func printable() -> String {
        return "\n\t Card \(actionCard.card.suit)\(actionCard.card.value)\n\tpoints = \(points)\n\tnumVisits = \(numVisits)\n"
    }
    
    func addChildren(child: Node) {
        var child = child
        child.parent = self
        self.children.append(child)
    }
    
    func addChildren(children: [Node]) {
        var children = children
        for child in children {
            child.parent = self
        }
        
        self.children.append(contentsOf: children)
    }
    
    func numberOfChildren() -> Int {
        return self.children.count
    }
    
    func isLeafNode() -> Bool {
        return self.children.count == 0
    }
}
