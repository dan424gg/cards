//
//  MonteCarloSearch.swift
//  Cards
//
//  Created by Daniel Wells on 9/3/24.
//

import Foundation

class MonteCarloSearch {
    var rolloutGS: RolloutGameState
    
    init(_ rolloutGS: RolloutGameState) {
        self.rolloutGS = rolloutGS
    }
    
    func search(_ num_threads: Int) -> CardItem {
        func average_children(_ master_tree: Tree) {
            guard let children = master_tree.head?.children else {
                print("no head")
                return
            }
            
            for child in children {
                child.points /= num_threads
            }
        }
        
        
        let master_tree: Tree = MonteCarloSearchAux(rolloutGS).search_aux()
        
        for _ in 0..<num_threads {
            Task {
                do {
                    self.combineChildren(master_tree, MonteCarloSearchAux(rolloutGS).search_aux())
                } catch {
                    print("error")
                }
            }
        }
        
        average_children(master_tree)
        
        return master_tree.evaluate()
    }
    
    private func combineChildren(_ masterTree: Tree, _ additionalTree: Tree) {
        guard var masterChildren = masterTree.head?.children else {
            print("masterChildren is empty")
            return
        }
        masterChildren.sort(by: { $0.actionCard.id < $1.actionCard.id })
        
        guard var additionalChildren = additionalTree.head?.children else {
            print("additionalChildren is empty")
            return
        }
        additionalChildren.sort(by: { $0.actionCard.id < $1.actionCard.id })
        
        let numChildren = masterTree.numChildrenPerParent
        for i in 0..<numChildren {
            guard masterChildren[i].actionCard.id == additionalChildren[i].actionCard.id else {
                print("children didn't match at index \(i)\nmaster: \(masterChildren[i].actionCard.id)  additional: \(additionalChildren[i].actionCard.id)")
                return
            }
            
            masterChildren[i].points += additionalChildren[i].points
        }
    }
    
    class MonteCarloSearchAux {
        var tree: Tree!
        var cur: Node!
        var head: Node!
        var rolloutGS: RolloutGameState
        
        init(_ rolloutGS: RolloutGameState) {
            self.rolloutGS = rolloutGS
        }
        
        func search_aux() -> Tree {
            rolloutGS.playerTwoHand = rolloutGS.deck.sample(4)
            tree = Tree(head: Node(points: 0, numVisits: 0, actionCard: CardItem(id: -1), parent: nil, children: [], rolloutGS: rolloutGS), 4)
            head = tree.head
            cur = head
            
            head?.children = createChildStates(head!)
            
            for i in 0..<300 {
                while !cur.isLeafNode() {
                    let children = cur.children
                    var maxUCB1 = Int.min
                    var bestNode: Node!
                    
                    children.forEach {
                        let childUCB1 = UCB1($0, head.numVisits)
                        
                        if childUCB1 > maxUCB1 {
                            maxUCB1 = childUCB1
                            bestNode = $0
                        }
                    }
                    
                    cur = bestNode
                }
                
                var v: Int = 0
                if cur.numVisits == 0 {
                    v = rollout(cur.rolloutGS)
                } else {
                    let newStates = createChildStates(cur)
                    cur.addChildren(children: newStates)
                    
                    if !newStates.isEmpty {
                        cur = newStates.randomElement()
                        v = rollout(cur.rolloutGS)
                    }
                }
                
                backpropagate(v)
            }
            
            return tree
        }
        
        func createChildStates(_ node: Node) -> [Node] {
            var newStates: [Node] = [Node]()
            var validMoves: [CardItem] = node.rolloutGS.getValidMoves(playerTurn: node.rolloutGS.currentPlayer)
            var numPlayersChecked: Int = 0
            
            while true && !node.rolloutGS.isTerminalState() {
                numPlayersChecked += 1
                validMoves = node.rolloutGS.getValidMoves(playerTurn: node.rolloutGS.currentPlayer)
                
                if validMoves.isEmpty {
                    if node.rolloutGS.currentPlayer == 1 {
                        node.rolloutGS.currentPlayer = 2
                    } else {
                        node.rolloutGS.currentPlayer = 1
                    }
                    
                    if numPlayersChecked > 1 {
                        node.rolloutGS.playCards = []
                        numPlayersChecked = 0
                    }
                } else {
                    break
                }
            }
            
            validMoves.forEach {
                let temp = node.rolloutGS.copy()
                temp.applyMove(move: $0)
                newStates.append(Node(points: 0, numVisits: 0, actionCard: $0, parent: node, children: [], rolloutGS: temp))
            }
            
            return newStates
        }
        
        func rollout(_ gamestate: RolloutGameState) -> Int {
            let copyGS: RolloutGameState = gamestate.copy()
            
            while !copyGS.isTerminalState() {
                var numPlayersChecked: Int = 0
                var validMoves: [CardItem] = []
                
                while true {
                    numPlayersChecked += 1
                    validMoves = copyGS.getValidMoves(playerTurn: copyGS.currentPlayer)
                    
                    if validMoves.isEmpty {
                        if copyGS.currentPlayer == 1 {
                            copyGS.currentPlayer = 2
                        } else {
                            copyGS.currentPlayer = 1
                        }
                        
                        if numPlayersChecked > 1 {
                            copyGS.playCards = []
                            numPlayersChecked = 0
                        }
                    } else {
                        break
                    }
                }
                
                if !validMoves.isEmpty {
                    copyGS.applyMove(move: validMoves.randomElement()!)
                }
            }
            
            return copyGS.evaluate()
        }
        
        func backpropagate(_ points: Int) {
            repeat {
                cur.points += points
                cur.numVisits += 1
                cur = cur.parent
            } while cur != nil
            
            cur = head
        }
        
        func UCB1(_ node: Node, _ totalVisits: Int, C: Int = 2) -> Int {
            let points: Double = Double(node.points)
            let visits: Double = Double(node.numVisits)
            let c: Double = Double(C)
            
            if visits == 0.0 {
                return Int.max
            } else {
                let lhs = (points / visits)
                let rhs = (c * sqrt(log(Double(totalVisits)) / visits))
                let output = lhs + rhs
                return Int(output)
            }
        }
    }
}
