//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @EnvironmentObject var firebase: FirebaseHelper
    @State var counter: Int = 0
    @State var show = false
            
    var body: some View {
        VStack {
            if show {
                Test(counter: counter)
                    .transition(.slide.combined(with: .opacity))
            }
            
            Button("increment") {
                counter += 1
            }
            
            Button("show counter") {
                show = true
            }
        }
    }
}

struct Test: View {
    var counter: Int
    @State var shownCounter: Int = 0
    
    var body: some View {
        Text("\(shownCounter)")
            .onAppear {
                print("shown")
                shownCounter = counter
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
