//
//  ColorSquare.swift
//  Cards
//
//  Created by Daniel Wells on 1/14/24.
//

import Foundation
import SwiftUI

struct ColorSquare: View, Hashable {
    var color: Color
    
    static func == (lhs: ColorSquare, rhs: ColorSquare) -> Bool {
        return lhs.color == rhs.color
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(color)
    }
    
    var body: some View {
        Rectangle().fill(color).aspectRatio(1.0, contentMode: .fill).scaleEffect(0.025)
    }
}
