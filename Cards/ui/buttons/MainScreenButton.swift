//
//  MainScreenButtons.swift
//  Cards
//
//  Created by Daniel Wells on 4/30/24.
//

import SwiftUI

struct MainScreenButton: View {
    @EnvironmentObject var specs: DeviceSpecs
    @State var scale: Double = 1.0

    var buttonType: IntroViewType
    var submitFunction: (() -> Void)
    
    var body: some View {
        CText(buttonType == .newGame ? "New Game" : "Join Game", size: 24)
            .foregroundStyle(specs.theme.colorWay.textColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
//            .font(.custom("LuckiestGuy-Regular", size: 24))
//            .baselineOffset(-5)
//            .foregroundStyle(buttonType == .newGame ? specs.theme.colorWay.secondary : specs.theme.colorWay.primary)
            .frame(width: specs.maxX * 0.75)
            .background(/*buttonType == .newGame ? specs.theme.colorWay.secondary : */specs.theme.colorWay.primary)
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
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
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

#Preview {
    GeometryReader { geo in
        MainScreenButton(buttonType: .newGame, submitFunction: { print("hello") })
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
}
