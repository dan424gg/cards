//
//  CustomTextField.swift
//  Cards
//
//  Created by Daniel Wells on 2/23/24.
//

import Foundation
import SwiftUI


struct CustomTextField: View {
    enum Field: Hashable {
        case value
    }
    
    @EnvironmentObject var specs: DeviceSpecs
    
    var textFieldHint: String
    
    @FocusState private var hasFocus: Bool
    @Binding var value: String
    @State private var maxX: Double = 0.0
    @State private var size: Double = 0.0
    
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
        }
        .onAppear {
            maxX = specs.maxX
            size = maxX * 0.33
        }
        .onChange(of: hasFocus, { (old, new) in
            withAnimation(.smooth(duration: 0.3)) {
                if hasFocus {
                    size = max(specs.maxX * 0.66, size > maxX ? maxX - 35 : size)
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
            .padding()
            .font(.custom("LuckiestGuy-Regular", size: 20))
            .offset(y: 2)
            .background(Color.theme.white)
            .clipShape(Capsule())
//            .background(
//                RoundedRectangle(cornerRadius: 30)
//                    .fill(Color.theme.white)
//                    .stroke(Color.theme.secondary, lineWidth: 1.0)
//            )
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
