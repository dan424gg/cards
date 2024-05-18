//
//  MultiplayerSubView.swift
//  Cards
//
//  Created by Daniel Wells on 5/17/24.
//

import SwiftUI

struct MultiplayerSubView: View {
    @Environment(GameHelper.self) var gameHelper
    @Environment(DeviceSpecs.self) var specs
    
    var body: some View {
        HStack(spacing: -10) {
            Group {
                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                    .overlay {
                        CText("New Game", size: 35)
                            .multilineTextAlignment(.center)
                    }
                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                    .overlay {
                        CText("Join Game", size: 35)
                            .multilineTextAlignment(.center)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            .scaleEffect(0.8)
        }
        .frame(width: specs.maxX * 0.75, height: 125)
        .background {
            RoundedRectangle(cornerRadius: 25.0)
                .fill(specs.theme.colorWay.primary)
        }
    }
}

#Preview {
    return GeometryReader { geo in
        MultiplayerSubView()
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
