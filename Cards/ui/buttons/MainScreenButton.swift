//
//  MainScreenButtons.swift
//  Cards
//
//  Created by Daniel Wells on 4/30/24.
//

import SwiftUI

struct MainScreenButton: View {
    @Environment(DeviceSpecs.self) private var specs
    @State var scale: Double = 1.0

    var buttonType: IntroViewType
    var submitFunction: (() -> Void)
    
    var body: some View {
        CText(determineText(buttonType), size: 24)
            .foregroundStyle(specs.theme.colorWay.textColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .frame(width: specs.maxX * 0.75)
            .background(specs.theme.colorWay.primary)
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
    
    func determineText(_ introView: IntroViewType) -> String {
        switch introView {
            case .newGame:
                return "NEW GAME"
            case .existingGame:
                return "JOIN GAME"
            case .singlePlayer:
                return "SINGLE PLAYER"
            case .multiPlayer:
                return "MULTIPLAYER"
            default:
                return "Nothing"
        }
    }
}

#Preview {
    GeometryReader { geo in
        MainScreenButton(buttonType: .newGame, submitFunction: { print("hello") })
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background(DeviceSpecs().theme.colorWay.background)
    }
}
