//
//  AlertWindow.swift
//  Cards
//
//  Created by Daniel Wells on 5/8/24.
//

import SwiftUI

struct Alert {
    var title: String = ""
    var message: String = ""
}

extension View {
    func alertWindow(_ alert: Binding<Alert?>) -> some View {
        modifier(AlertWindow(alert: alert))
    }
}

struct AlertWindow: ViewModifier {
    
    @EnvironmentObject private var specs: DeviceSpecs
    @Binding var alert: Alert?
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if alert != nil {
                    ZStack {
                        VStack(spacing: 15) {
                            CText(alert!.title, size: 28)
                                .foregroundStyle(specs.theme.colorWay.secondary)
                                .frame(height: 28)
                            CText(alert!.message, size: 18)
                                .multilineTextAlignment(.center)
                            CustomButton(name: "OKAY", submitFunction: {
                                withAnimation(.smooth.speed(1.5)) {
                                    alert = nil
                                }
                            }, size: 18)
                        }
                        .frame(width: 250)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(specs.theme.colorWay.primary)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .stroke(specs.theme.colorWay.secondary, lineWidth: 7.0)
                                }
                        }
                    }
                    .onAppear {
                        endTextEditing()
                    }
                    .frame(width: specs.maxX, height: specs.maxY)
                    .background {
                        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                            .ignoresSafeArea()
                    }
                    .geometryGroup()
                    .transition(.opacity.animation(.smooth.speed(1.5)))
                }
            }
    }
}

#Preview {
    let alert = Alert(title: "Error", message: "This is a message saying that there was an error in the app!")
    return GeometryReader { geo in
        Text("")
            .alertWindow(.constant(alert))
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .background(DeviceSpecs().theme.colorWay.background)
    .ignoresSafeArea()
}

