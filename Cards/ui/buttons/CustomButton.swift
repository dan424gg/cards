//
//  CustomButton.swift
//  Cards
//
//  Created by Daniel Wells on 4/29/24.
//

import SwiftUI

struct CustomButton: View {
    @EnvironmentObject var specs: DeviceSpecs
    var name: String
    var submitFunction: (() -> Void)
    var size: Int?
    var invertColors: Bool = false
    @State private var scale: Double = 1.0

    var body: some View {
        CText(name, size: size ?? 24)
            .foregroundStyle(invertColors ? specs.theme.colorWay.secondary : specs.theme.colorWay.primary)
            .padding(.horizontal, CGFloat((size ?? 24)) * 0.833)
            .padding(.vertical, CGFloat((size ?? 24)) * 0.5)
            .background(invertColors ? specs.theme.colorWay.primary : specs.theme.colorWay.secondary)
            .clipShape(Capsule())
            .scaleEffect(scale)
            .onLongPressGesture(minimumDuration: 100.0, maximumDistance: 50.0, perform: {
                withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                    submitFunction()
                    scale = 1.0
                }
            }, onPressingChanged: { change in
                if change {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.bouncy(duration: 0.3)) {
                        scale = 0.9
                    }
                } else {
                    withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                        submitFunction()
                        scale = 1.0
                    }
                }
            })
    }
}

struct ImageButton: View {
    var image: Image
    var submitFunction: (() -> Void)
    
    @State var scale: Double = 1.0

    var body: some View {
        image
            .scaleEffect(scale)
            .onLongPressGesture(minimumDuration: 100.0, perform: {
                withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                    submitFunction()
                    scale = 1.0
                }
            }, onPressingChanged: { change in
                if change {
                    withAnimation(.bouncy(duration: 0.3)) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        scale = 0.85
                    }
                } else {
                    withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                        submitFunction()
                        scale = 1.0
                    }
                }
            })
        
    }
}

#Preview {
    CustomButton(name: "Submit", submitFunction: { print("hi") })
}
