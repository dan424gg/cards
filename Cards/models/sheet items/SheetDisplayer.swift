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
    @State var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.currentSheet, onDismiss: {
                print("dismissed")
                detentSelected = .fraction(0.02)
            }, content: { sheet in
                GeometryReader { geo in
                    sheet
                        .view(coordinator: coordinator)
                        .padding()
                        .opacity(opacity)
                        .onAppear {
                            detentSelected = sheet.detents.first!
                        }
                        .presentationCornerRadius(45.0)
                        .presentationDetents(Set(sheet.detents), selection: $detentSelected)
                        .interactiveDismissDisabled()
                        .onChange(of: geo.frame(in: .local).height, { 
                            if (geo.frame(in: .global).height / geo.frame(in: .global).maxY <= 0.1) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    opacity = ((((geo.frame(in: .global).height / geo.frame(in: .global).maxY) - 0.02) / 0.8) * 10)
                                    print(opacity)
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    opacity = 1.0
                                }
                            }
                        })
                }
            })
    }
}
