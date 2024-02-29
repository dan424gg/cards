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
    @Binding var value: String
    @State private var maxX: Double = 0.0
    @State private var size: Double = 0.0
    
    var body: some View {
//        GeometryReader { geo in
            VStack {
                TextField(
                    "\(textFieldHint)",
                    text: $value
                )
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
            withAnimation(.snappy(duration: 0.5)) {
                if hasFocus {
                    size = max(specs.maxX * 0.66, size > maxX ? maxX - 35 : size)
                } else {
                    size = value == "" ? maxX * 0.33 : value.width(usingFont: UIFont.systemFont(ofSize: 15)) + 35
                }
            }
        })
    }
}

struct TextFieldBorder: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 15))
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.white)
                    .stroke(Color("OffWhite"), lineWidth: 1.0)
            )
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
