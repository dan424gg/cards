//
//  CribMarker.swift
//  Cards
//
//  Created by Daniel Wells on 4/10/24.
//

import SwiftUI

struct CribMarker: View {
    @EnvironmentObject var specs: DeviceSpecs
    var scale: Double = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.yellow)
                .frame(width: 40 * scale)

            Circle()
                .stroke(.white, lineWidth: 3 * scale)
                .frame(width: 30 * scale)
            
            Text("C")
                .font(.custom("LuckiestGuy-Regular", size: 21 * scale))
                .baselineOffset(-7 * scale)
                .foregroundStyle(.black)
        }
        .frame(width: 40 * scale)
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
