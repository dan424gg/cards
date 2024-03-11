//
//  ContentView.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @State var blur: Bool = false
        
    var body: some View {
        ZStack {
            MainView(visible: $blur)
                .zIndex(1.0)
//                .background {
                    ZStack {
                        Color("OffWhite")
                            .opacity(0.07)
                        ForEach(Array(0...20), id: \.self) { i in
                            LineOfSuits(index: i)
                                .offset(y: CGFloat(-85 * i))
                        }
                        .position(x: specs.maxX / 2, y: specs.maxY * 1.5)
                    }
                    .zIndex(0.0)
                    .blur(radius: blur ? 3 : 0)
//                }
                .sheetDisplayer(coordinator: sheetCoordinator)
        }
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
