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
//    @Published var detents: [PresentationDetent] = []
//    private var sheetStack: [Sheet] = []

    @MainActor
    func showSheet(_ sheet: Sheet) {
        currentSheet = sheet
//        sheetStack.append(sheet)
//        
//        if sheetStack.count == 1 {
//            currentSheet = sheet
//        }
    }

//    @MainActor
//    func removeSheet() {
//        sheetStack.removeFirst()
//
//        if let nextSheet = sheetStack.first {
//            currentSheet = nextSheet
//        }
//    }
}
