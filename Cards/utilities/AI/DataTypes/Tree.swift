//
//  Tree.swift
//  Cards
//
//  Created by Daniel Wells on 9/3/24.
//

import Foundation

class Tree {
    var head: Node?
    var numChildrenPerParent: Int
    
    init(head: Node? = nil, _ numChildrenPerParent: Int) {
        self.head = head
        self.numChildrenPerParent = numChildrenPerParent
    }
    
    func evaluate() -> CardItem {
        guard let children = self.head?.children else {
            print("head didn't have any children when the tree was about to be evaluated!")
            return CardItem(id: -1)
        }
        
        if let bestChild = children.sorted(by: {$0.points < $1.points}).last {
            return bestChild.actionCard
        } else {
            print("couldn't find a best child")
            return CardItem(id: -1)
        }
    }
}
