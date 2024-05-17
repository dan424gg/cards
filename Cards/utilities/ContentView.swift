//
//  ContentView.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import Combine

struct NamespaceEnvironmentKey: EnvironmentKey {
    static var defaultValue: Namespace.ID = Namespace().wrappedValue
}

extension EnvironmentValues {
    var namespace: Namespace.ID {
        get { self[NamespaceEnvironmentKey.self] }
        set { self[NamespaceEnvironmentKey.self] = newValue }
    }
}

extension View {
    func namespace(_ value: Namespace.ID) -> some View {
        environment(\.namespace, value)
    }
}

struct ContentView: View {
    @Environment(GameHelper.self) private var gameHelper
    @Environment(DeviceSpecs.self) private var specs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @State var blur: Bool = false
    
    @Namespace var namespace
        
    var body: some View {
//        SwiftUIView()
//            .position(x: specs.maxX / 2, y: specs.maxY / 2)
        NavigationStack {
            ZStack {
                MainView()
                    .zIndex(1.0)
                    .namespace(namespace)
                
                ZStack {
                    specs.theme.colorWay.background
                    ForEach(Array(0...20), id: \.self) { i in
                        LineOfSuits(index: i)
                            .offset(y: CGFloat(-120 * Double(i)))
                    }
                    .position(x: specs.maxX / 2, y: specs.maxY * 1.5)
                }
                .zIndex(0.0)
            }
            .ignoresSafeArea()
        }
        .background {
            DeviceSpecs().theme.colorWay.background
        }
        .overlay {
            #if DEBUG
            Text("DEBUG MODE")
                .font(.system(size: 50))
                .opacity(0.5)
                .position(x: specs.maxX / 2, y: specs.maxY * 0.95)
                .allowsHitTesting(false)
            #endif
        }
        .statusBarHidden(true)
    }
}

#Preview {
    return GeometryReader { geo in
        ContentView()
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
    }
    .ignoresSafeArea()
}
