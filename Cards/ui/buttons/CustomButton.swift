//
//  CustomButton.swift
//  Cards
//
//  Created by Daniel Wells on 4/29/24.
//

import SwiftUI

struct CustomButton: View {
    @EnvironmentObject var specs: DeviceSpecs
    @GestureState private var isPressed = false
    @State var lastPressTime: Date?
    @State var isDragging: Bool = false
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
            .onLongPressGesture(minimumDuration: 5.0, maximumDistance: 150.0, perform: {
                withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                    handleButtonPress()
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
                        handleButtonPress()
                        scale = 1.0
                    }
                }
            })
    }

    func handleButtonPress() {
        let currentTime = Date()
        
        // Check if the button was pressed recently
        if let lastPress = lastPressTime, currentTime.timeIntervalSince(lastPress) < 2 {
            print("Button press ignored, too soon after last press \(lastPress).")
            return
        }

        // Update the last press time
        lastPressTime = currentTime
        
        withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
            submitFunction()
//            scale = 1.0
        }
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
    return GeometryReader { geo in
        CustomButton(name: "Submit", submitFunction: { print("hi") })
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
        
    }
    .ignoresSafeArea()
}
