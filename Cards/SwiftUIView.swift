//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @State var isRunning: Bool = true
    @State var isReversing: Bool = false
    
    var body: some View {
        ZStack {
            LineOfSuits(index: 0)
            HStack {
                Button(isRunning ? "Pause" : "Play"){
                    isRunning.toggle()
                }
                
                Button("Reverse") {
                    isReversing.toggle()
                }
            }
            .offset(x: -25, y: -200)
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    let deviceSpecs = DeviceSpecs()
    
    return GeometryReader { geo in
        SwiftUIView()
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
