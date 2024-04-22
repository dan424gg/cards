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
    var validationFunciton: ((String) -> Void)? = nil
    
    @FocusState private var hasFocus: Bool
    @Binding var value: String
    @State private var maxX: Double = 0.0
    @State private var size: Double = 0.0
    
    var body: some View {
        VStack {
            TextField(
                "",
                text: $value,
                prompt: Text("\(textFieldHint)").foregroundStyle(.gray.opacity(0.4))
            )
            .onChange(of: hasFocus, {
                guard validationFunciton != nil, !value.isEmpty else {
                    return
                }
                
                validationFunciton!(value)
            })
            .focused($hasFocus)
            .frame(width: size)
            .textFieldStyle(TextFieldBorder())
            .multilineTextAlignment(.center)
        }
        .onAppear {
            maxX = specs.maxX
            size = maxX * 0.33
        }
        .onChange(of: hasFocus, { (old, new) in
            withAnimation(.smooth(duration: 0.3)) {
                if hasFocus {
                    size = max(specs.maxX * 0.6, size > maxX ? maxX - 35 : size)
                } else {
                    size = value == "" ? maxX * 0.33 : value.width(usingFont: UIFont.init(name: "LuckiestGuy-Regular", size: 25)!) + 35
                }
            }
        })
    }
}

struct TextFieldBorder: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom("LuckiestGuy-Regular", size: 24))
            .baselineOffset(-2)
            .padding(.vertical, 18)
            .background(Color.white)
            .clipShape(Capsule())
    }
}

#Preview {
    let deviceSpecs = DeviceSpecs()
    
    return GeometryReader { geo in
        CustomTextField(textFieldHint: "Name", value: .constant(""))
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
}
