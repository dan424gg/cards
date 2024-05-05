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
    
    @State var scale: Double = 1.0

    var body: some View {
        Text(name)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .font(.custom("LuckiestGuy-Regular", size: 24))
            .baselineOffset(-5)
            .foregroundStyle(specs.theme.colorWay.primary)
            .background(specs.theme.colorWay.secondary)
            .clipShape(Capsule())
            .scaleEffect(scale)
            .onLongPressGesture(minimumDuration: 100.0, perform: {
                withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                    submitFunction()
                    scale = 1.0
                }
            }, onPressingChanged: { change in
                if change {
                    withAnimation(.bouncy(duration: 0.3)) {
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
