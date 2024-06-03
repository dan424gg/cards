//
//  TextButton.swift
//  Cards
//
//  Created by Daniel Wells on 5/17/24.
//

import SwiftUI

struct TextButton: View {
    var text: String
    var submitFunction: (() -> Void)

    @State var scale: Double = 0.8
    
    var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
            .overlay {
                CText(text, size: 35)
                    .multilineTextAlignment(.center)
            }
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            .scaleEffect(scale)
            .onLongPressGesture(minimumDuration: 100.0, maximumDistance: 50.0, perform: {
                withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                    submitFunction()
                    scale = 0.8
                }
            }, onPressingChanged: { change in
                if change {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.bouncy(duration: 0.3)) {
                        scale = 0.7
                    }
                } else {
                    withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                        submitFunction()
                        scale = 0.8
                    }
                }
            })
    }
}

#Preview {
    return GeometryReader { geo in
        TextButton(text: "New Game", submitFunction: {
            print("hi")
        })
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background {
                DeviceSpecs().theme.colorWay.background
            }
    }
    .ignoresSafeArea()
}
