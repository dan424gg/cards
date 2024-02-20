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
    
    @ViewBuilder
    func view(coordinator: SheetCoordinator<Self>) -> Body
}

enum SheetType: String, Identifiable, SheetEnum {
    case newGame, existingGame, loadingScreen, gamePlay

    var id: String { rawValue }

    @ViewBuilder
    func view(coordinator: SheetCoordinator<SheetType>) -> some View {
        switch self {
            case .newGame:
                NewGame()
            case .existingGame:
                ExistingGame()
            case .loadingScreen:
                LoadingScreen()
            case .gamePlay:
                Text("this is the game play!")
        }
    }
}
