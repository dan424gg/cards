//
//  SheetCordinating.swift
//  Cards
//
//  Created by Daniel Wells on 2/20/24.
//

import Foundation
import SwiftUI

struct SheetDisplayer<Sheet: SheetEnum>: ViewModifier {
    @StateObject var coordinator: SheetCoordinator<Sheet>
    @State var detentSelected: PresentationDetent = .height(0.0)

    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.currentSheet, onDismiss: {
                print("dismissed")
                detentSelected = .fraction(0.02)
            }, content: { sheet in
                sheet
                    .view(coordinator: coordinator)
                    .onAppear {
                        detentSelected = sheet.detents.first!
                    }
                    .presentationCornerRadius(57.0)
                    .presentationDetents(Set(sheet.detents), selection: $detentSelected)
                    .interactiveDismissDisabled()
            })
    }
}
