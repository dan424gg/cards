//
//  DeviceSpecs.swift
//  Cards
//
//  Created by Daniel Wells on 2/22/24.
//

import Foundation
import SwiftUI

class DeviceSpecs: ObservableObject {
    @Published var size: CGSize = .zero
    @Published var maxX: Double = 0.0
    @Published var maxY: Double = 0.0
    @Published var inGame: Bool = false
    @AppStorage(AppStorageConstants.theme) var theme: ColorTheme = .classic
    
    func setProperties(_ geo: GeometryProxy) {
        size = geo.frame(in: .global).size
        maxX = geo.frame(in: .global).maxX
        maxY = geo.frame(in: .global).maxY
    }
}
