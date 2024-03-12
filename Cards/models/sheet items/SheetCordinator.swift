//
//  SheetCordinator.swift
//  Cards
//
//  Created by Daniel Wells on 2/20/24.
//

import Foundation
import SwiftUI

final class SheetCoordinator<Sheet: SheetEnum>: ObservableObject {
    @Published var currentSheet: Sheet?

    @MainActor
    func showSheet(_ sheet: Sheet) {       
        currentSheet = sheet
    }
}
