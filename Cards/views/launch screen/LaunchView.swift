//
//  LaunchView.swift
//  Cards
//
//  Created by Daniel Wells on 3/13/24.
//

import SwiftUI
import Combine

struct LaunchView: View {
    @Binding var showLaunch: Bool
    @EnvironmentObject var specs: DeviceSpecs
    @State var timer: Timer?
    
    var body: some View {
        ZStack {
            specs.theme.colorWay.background
            
            // used for creating screenshot of CText
//            CText("Cards")
//                .font(.custom("LuckiestGuy-Regular", size: 70.0))
//                .foregroundStyle(BananaColorWay().title)
            
            switch specs.theme {
                case .classic:
                    Image("CardGame_Cards")
                        .resizable()
                        .aspectRatio(332/85, contentMode: .fit)
                        .frame(width: 200)
                case .banana:
                    Image("Banana_Cards")
                        .resizable()
                        .aspectRatio(332/85, contentMode: .fit)
                        .frame(width: 200)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { _ in
                withAnimation(.snappy(duration: 0.3)) {
                    showLaunch = false
                }
            })
        }
    }
}

#Preview {
    GeometryReader { geo in
        LaunchView(showLaunch: .constant(false))
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(GameHelper())
    }
    .ignoresSafeArea()
    .background {
        DeviceSpecs().theme.colorWay.background
    }
}
