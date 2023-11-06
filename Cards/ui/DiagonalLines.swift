//
//  DiagonalLines.swift
//  Cards
//
//  Created by Daniel Wells on 11/1/23.
//

import Foundation
import SwiftUI

struct DiagonalLines: Shape {
    func path(in rect: CGRect) -> Path {
            var path = Path()
            let lineSpacing: CGFloat = 10

            for x in stride(from: -rect.width, through: rect.width, by: lineSpacing) {
                path.move(to: CGPoint(x: x, y: rect.minY))
                path.addLine(to: CGPoint(x: x + rect.width, y: rect.maxY))
            }

            return path
        }
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        
//        for i in stride(from: 0, to: rect.maxX, by: 10) {
//            path.move(to: CGPoint(x: i, y: 0))
//            path.addLine(to: CGPoint(x: i - rect.maxX, y: rect.maxY))
//        }
//        
//        return path
//    }
}
