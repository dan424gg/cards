//
//  DeviceSpecs.swift
//  Cards
//
//  Created by Daniel Wells on 2/22/24.
//

import Foundation
import SwiftUI

@Observable class DeviceSpecs {
    var size: CGSize = .zero
    var maxX: Double = 0.0
    var maxY: Double = 0.0
    var inGame: Bool = false
    var singlePlayerModelUid: UUID? = nil
    var theme: ColorTheme = .classic
    
    func setProperties(_ geo: GeometryProxy) {
        size = geo.frame(in: .global).size
        maxX = geo.frame(in: .global).maxX
        maxY = geo.frame(in: .global).maxY
    }
}
