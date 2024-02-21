//
//  SheetEnum.swift
//  Cards
//
//  Created by Daniel Wells on 2/20/24.
//

import Foundation
import SwiftUI

protocol SheetEnum: Identifiable {
    associatedtype Body: View
    
    var detents: Array<PresentationDetent> { get }
    
    @ViewBuilder
    func view(coordinator: SheetCoordinator<Self>) -> Body
}

enum SheetType: String, Identifiable, SheetEnum {
    case newGame, existingGame, loadingScreen, gameStats

    var id: String { rawValue }
    var detents: Array<PresentationDetent> {
        switch self {
            case .newGame:
                [.fraction(0.30)]
            case .existingGame:
                [.fraction(0.36)]
            case .loadingScreen:
                [.fraction(0.35), .fraction(0.045)]
            case .gameStats:
                [.fraction(0.35), .fraction(0.045)]
        }
    }

    @ViewBuilder
    func view(coordinator: SheetCoordinator<SheetType>) -> some View {
        switch self {
            case .newGame:
                NewGame(sheetCoordinator: coordinator)
            case .existingGame:
                ExistingGame(sheetCoordinator: coordinator)
            case .loadingScreen:
                LoadingScreen()
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled)
            case .gameStats:
                Text("this is the game stats!")
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled)
        }
    }
}
