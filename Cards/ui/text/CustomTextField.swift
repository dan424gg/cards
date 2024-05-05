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
                prompt: Text(textFieldHint).foregroundStyle(.gray.opacity(0.5))
            )
            .onChange(of: hasFocus, {
                guard !value.isEmpty else {
                    return
                }
                
                if UserDefaults.standard.bool(forKey: AppStorageConstants.filter) {
                    value = ProfanityFilter.cleanUp(value)
                }
                
                if validationFunciton != nil {
                    validationFunciton!(value)
                }
            })
            .focused($hasFocus)
            .frame(width: specs.maxX * 0.5)
            .textFieldStyle(TextFieldBorder())
            .multilineTextAlignment(.center)
        }
    }
}

struct TextFieldBorder: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .font(.custom("LuckiestGuy-Regular", size: 24))
            .baselineOffset(-2.5)
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
            .background {
                DeviceSpecs().theme.colorWay.background
            }
    }
}
