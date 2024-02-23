//
//  CustomTextField.swift
//  Cards
//
//  Created by Daniel Wells on 2/23/24.
//

import Foundation
import SwiftUI


struct CustomTextField: View {
    @EnvironmentObject var specs: DeviceSpecs
    
    var textFieldHint: String
    
    @FocusState private var hasFocus: Bool
    @State private var value: String = ""
    @State private var maxX: Double = 0.0
    @State private var size: Double = 0.0
    @State private var nextView: Bool = false
    
    var body: some View {
        VStack {
            TextField(
                "\(textFieldHint)",
                text: $value
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
                    size = value == "" ? specs.maxX * 0.33 : value.width(usingFont: UIFont.systemFont(ofSize: 15)) + 50
                }
            }
        })
    }
}

#Preview {
    let deviceSpecs = DeviceSpecs()
    
    return GeometryReader { geo in
        CustomTextField(textFieldHint: "Name")
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
}
