//
//  runner.swift
//  Cards
//
//  Created by Daniel Wells on 9/3/24.
//

import Foundation
    
func search(_ gamehelper: nonMainActorGameHelper) -> Int {
    let rolloutGS = RolloutGameState(gamehelper)
    let mcs = MonteCarloSearch(rolloutGS)

    let start = Date()
    let output = mcs.search(1000).id
    let end = Date()
    
    let elapsedTime = end.timeIntervalSince(start)
    print("Elapsed time: \(elapsedTime) seconds")
    
    return output
}
