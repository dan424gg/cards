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
    @State var detentSelected: PresentationDetent = .large
    @State var opacity: Double = 1.0
    @State var offset: Double = 0.0

    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.currentSheet, content: { sheet in
                GeometryReader { geo in
                    sheet
                        .view(coordinator: coordinator)
                        .opacity(opacity)
                        .onAppear {
                            detentSelected = sheet.detents.first!
                        }
                        .padding(geo.frame(in: .global).maxY * 0.0587)
                        .presentationCornerRadius(45.0)
                        .presentationDragIndicator(.visible)
                        .presentationDetents(Set(sheet.detents), selection: $detentSelected)
                        .onChange(of: geo.frame(in: .local).height, { (old, new) in
                            if (geo.frame(in: .global).height / geo.frame(in: .global).maxY <= 0.1) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    opacity = ((((new / geo.frame(in: .global).maxY) - 0.045) / 0.8) * 10)
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    opacity = 1.0
                                }
                            }
                        })
                        .frame(alignment: .center)
                }
            })
    }
}
