//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @EnvironmentObject private var specs: DeviceSpecs
    @State var name: String = ""
    @State private var maxX: Double = 0.0
    @State private var size: Double = 0.0
    @State private var nextView: Bool = false
    @FocusState private var hasFocus: Bool
    
    var body: some View {
        VStack {
            TextField(
                "Name",
                text: $name
            )
            .focused($hasFocus)
            .frame(width: size)
            .textFieldStyle(TextFieldBorder())
            .multilineTextAlignment(.center)
            .disabled(nextView)
        }
        .onChange(of: specs.maxX, initial: true, {
            if specs.maxX != 0.0 {
                size = specs.maxX * 0.33
            }
        })
        .onChange(of: hasFocus, { (old, new) in
            withAnimation(.snappy(duration: 0.5)) {
                if hasFocus {
                    size = max(specs.maxX * 0.66, size + 50 > specs.maxX ? specs.maxX - 50 : size + 50)
                } else {
                    size = name == "" ? specs.maxX * 0.33 : name.width(usingFont: UIFont.systemFont(ofSize: 15)) + 50
                }
            }
        })
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
}
