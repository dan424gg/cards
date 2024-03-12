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
    @State var detentSelected: PresentationDetent = .fraction(0.25)
    @State var detents: [PresentationDetent] = [.fraction(0.25)]
    @State var opacity: Double = 1.0
    @State var offset: Double = 0.0

    func body(content: Content) -> some View {
        content
            .sheet(item: $coordinator.currentSheet, content: { sheet in
                GeometryReader { geo in
                    sheet
                        .view(coordinator: coordinator)
                        .opacity(opacity)
                        .presentationCornerRadius(45.0)
                        .presentationDragIndicator(.visible)
                        .presentationDetents(Set(detents), selection: $detentSelected)
                        .presentationBackground(.thinMaterial)
                        .onChange(of: geo.frame(in: .local).height, { (old, new) in
                            print(geo.frame(in: .local).height, geo.frame(in: .global).maxY)
                            if ((geo.frame(in: .local).height / geo.frame(in: .global).maxY) <= 0.2) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    opacity = ((((new / geo.frame(in: .global).maxY) - 0.08) / 0.8) * 10)
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    opacity = 1.0
                                }
                            }
                        })
                }
                .ignoresSafeArea()
            })
            .onChange(of: coordinator.currentSheet, initial: true, { (old, new) in
                guard coordinator.currentSheet != nil else {
                    return
                }
                
                detents = new!.detents.filter({ $0 != .large })
                detentSelected = detents.first!
            })
    }
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

struct ClearBackgroundViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .background(ClearBackgroundView())
    }
}

extension View {
    func clearModalBackground()->some View {
        self.modifier(ClearBackgroundViewModifier())
    }
}

#Preview {
    return GeometryReader { geo in
        ContentView()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .ignoresSafeArea()
}
