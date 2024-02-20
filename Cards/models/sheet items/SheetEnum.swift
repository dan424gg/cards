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
                [.large]
            case .existingGame:
                [.large]
            case .loadingScreen:
                [.medium, .fraction(0.02)]
            case .gameStats:
                [.medium, .fraction(0.02)]
        }
    }

    @ViewBuilder
    func view(coordinator: SheetCoordinator<SheetType>) -> some View {
        switch self {
            case .newGame:
                NewGame()
            case .existingGame:
                ExistingGame()
            case .loadingScreen:
                LoadingScreen()
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
            case .gameStats:
                Text("this is the game stats!")
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled)
        }
    }
}
