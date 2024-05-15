//
//  SheetEnum.swift
//  Cards
//
//  Created by Daniel Wells on 2/20/24.
//

import Foundation
import SwiftUI

protocol SheetEnum: Equatable, Identifiable {
    associatedtype Body: View
    
    var detents: Array<PresentationDetent> { get }
    
    @ViewBuilder
    func view(coordinator: SheetCoordinator<Self>) -> Body
}

enum SheetType: Identifiable, SheetEnum {
    case gameSetUp(type: GameSetUpType), loadingScreen, gameStats

    var id: String {
        switch self {
            case .loadingScreen:
                return "loadingScreen"
            case .gameStats:
                return "gameStats"
            case .gameSetUp:
                return "gameSetUp"
        }
    }
    
    var detents: Array<PresentationDetent> {
        switch self {
            case .gameSetUp:
                [.fraction(0.25)]
            case .loadingScreen:
                [.fraction(0.4), .fraction(0.045), .large]
            case .gameStats:
                [.fraction(0.25), .fraction(0.045), .large]
        }
    }

    @ViewBuilder
    func view(coordinator: SheetCoordinator<SheetType>) -> some View {
        Text("nothing")
//        switch self {
//            case .gameSetUp(let type):
//                GameSetUpView(sheetCoordinator: coordinator, setUpType: type)
//            case .loadingScreen:
//                LoadingScreen(intro)
//                    .interactiveDismissDisabled()
//                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.045)))
//            case .gameStats:
//                CText("this is the game stats!")
//                    .interactiveDismissDisabled()
//                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.045)))
//        }
    }
}
