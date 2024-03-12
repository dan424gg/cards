//
//  SideBar.swift
//  Cards
//
//  Created by Daniel Wells on 3/7/24.
//

import SwiftUI
import Combine

struct SideBar: View {
    @EnvironmentObject var specs: DeviceSpecs
    @State var size: CGSize = CGSize(width: 1.0, height: 1.0)
    @State var timer: Timer?
    @State var opacity: Double = 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20.0)
            .fill(.red)
            .opacity(opacity)
            .shadow(radius: 5)
            .scaleEffect(size)
            .onLongPressGesture(minimumDuration: 1.0, perform: {
                timer?.invalidate()
                timer = nil
                withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                    size = CGSize(width: 1.0, height: 1.0)
                    opacity = 0.5
                }
            }, onPressingChanged: { change in
                if change {
                    timer?.invalidate()
                    timer = nil
                    withAnimation(.bouncy(duration: 0.3)) {
                        size = CGSize(width: 0.85, height: 0.85)
                        opacity = 0.9
                    }
                } else {
                    withAnimation(.bouncy(duration: 0.3, extraBounce: 0.4)) {
                        size = CGSize(width: 1.0, height: 1.0)
                    }

                    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
                        withAnimation(.smooth(duration: 0.3)) {
                            opacity = 0.5
                        }
                    })
                }
            })
            .frame(width: 7, height: 200)
            .position(x: specs.maxX - 20.0, y: specs.maxY / 2)
    }
}

#Preview {
    return GeometryReader { geo in
        SideBar()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .ignoresSafeArea()
}
