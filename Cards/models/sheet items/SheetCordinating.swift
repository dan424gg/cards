//
//  SheetCordinating.swift
//  Cards
//
//  Created by Daniel Wells on 2/20/24.
//

import Foundation
import SwiftUI

struct SheetCoordinating<Sheet: SheetEnum>: ViewModifier {
    @StateObject var coordinator: SheetCoordinator<Sheet>

    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.currentSheet, onDismiss: {
                coordinator.sheetDismissed()
            }, content: { sheet in
                sheet
                    .view(coordinator: coordinator)
//                    .animation(.smooth, value: detentSelection)
//                    .presentationCornerRadius(57.0)
//                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.02)))
//                    .presentationDetents(detents, selection: $detentSelection)
//                    .presentationDragIndicator(.visible)
//                    .interactiveDismissDisabled()
            })
    }
}
