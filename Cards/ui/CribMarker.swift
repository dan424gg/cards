//
//  CribMarker.swift
//  Cards
//
//  Created by Daniel Wells on 4/10/24.
//

import SwiftUI

struct CribMarker: View {
    @Environment(\.namespace) var namespace
    @EnvironmentObject var specs: DeviceSpecs
    var scale: Double = 1.0
    
    @State var scaleEffect: Double = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.yellow)
                .frame(width: 40 * scale)

            Circle()
                .stroke(.white, lineWidth: 3 * scale)
                .frame(width: 30 * scale)
            
            CText("C", size: Int(21 * scale))
                .foregroundStyle(.black)
        }
        .frame(width: 40 * scale)
        .scaleEffect(scaleEffect)
        .onLongPressGesture(minimumDuration: 100.0, perform: {
            withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                scaleEffect = 1.0
            }
        }, onPressingChanged: { change in
            if change {
                withAnimation(.bouncy(duration: 0.3)) {
                    scaleEffect = 0.85
                }
            } else {
                withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                    scaleEffect = 1.0
                }
            }
        })
    }
}

#Preview {
    return GeometryReader { geo in
        CribMarker()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .environmentObject(FirebaseHelper())
    }
    .ignoresSafeArea()
}
