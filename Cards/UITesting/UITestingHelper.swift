//
//  UITestingHelper.swift
//  Cards
//
//  Created by Daniel Wells on 2/5/24.
//

#if DEBUG

import Foundation

struct UITestingHelper {
    
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-testing")
    }
    
//    to access environmentValues ->   ProcessInfo.processInfo.environment[""] == "1"
}

#endif
