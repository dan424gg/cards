//
//  LineOfSuits.swift
//  Cards
//
//  Created by Daniel Wells on 2/29/24.
//

import SwiftUI
import Combine

struct LineOfSuits: View {
    @EnvironmentObject var specs: DeviceSpecs

    var index: Int
    var array: [Int] = Array(0...19)
    
    @State var pos = CGPoint(x: 0.0, y: 0.0)
    @State var pos2 = CGPoint(x: 0.0, y: 0.0)
    @State var duration: Double = 80.0
    
    var body: some View {
        ZStack {
            ZStack {
                ForEach(array, id: \.self) { i in
                    switch ((i + index) % 4) {
                        case 0:
                            SuitImage(suit: "diamond", index: CGFloat(i))
                        case 1:
                            SuitImage(suit: "club", index: CGFloat(i))
                        case 2:
                            SuitImage(suit: "heart", index: CGFloat(i))
                        case 3:
                            SuitImage(suit: "spade", index: CGFloat(i))
                        default:
                            EmptyView()
                    }
                }
            }
            .zIndex(0)
            .position(pos)
            .onAppear {
                let maxX = specs.maxX + 5.0
                let maxY = specs.maxY + 5.0
                
                pos = CGPoint(x: maxX / 2, y: maxY / 2)
                withAnimation(.linear(duration: duration / 2)) {
                    pos = CGPoint(x: -maxX / 2, y: maxY * 1.5)
                } completion: {
                    pos = CGPoint(x: maxX * 1.5, y: -maxY / 2)
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        pos = CGPoint(x: -maxX / 2, y: maxY * 1.5)
                    }
                }
            }
            
            ZStack {
                ForEach(array, id: \.self) { i in
                    switch ((i + index) % 4) {
                        case 0:
                            SuitImage(suit: "diamond", index: CGFloat(i))
                        case 1:
                            SuitImage(suit: "club", index: CGFloat(i))
                        case 2:
                            SuitImage(suit: "heart", index: CGFloat(i))
                        case 3:
                            SuitImage(suit: "spade", index: CGFloat(i))
                        default:
                            EmptyView()
                    }
                }
            }
            .zIndex(0)
            .position(pos2)
//            .offset(x: -5, y: -5)
            .onAppear {
                let maxX = specs.maxX + 5.0
                let maxY = specs.maxY + 5.0
                
                pos2 = CGPoint(x: maxX * 1.5, y: -maxY / 2)
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    pos2 = CGPoint(x: -maxX / 2, y: maxY * 1.5)
                }
            }
        }
    }
    
    struct SuitImage: View {
        @EnvironmentObject var specs: DeviceSpecs
        
        var suit: String
        var index: CGFloat
        
        @State var pos = CGPoint(x: 0.0, y: 0.0)
        
        var body: some View {
            Image(systemName: "suit.\(suit)")
                .foregroundColor(suit == "spade" || suit == "club" ? .black.opacity(0.3) : .red.opacity(0.3))
                .position(x: specs.maxX - CGFloat(Double(index) * (specs.maxX / 20.0)), y: (Double(index) * (specs.maxY / 20.0)))
//                .position(pos)
//                .onAppear {
//                    pos = CGPoint(x: ((specs.maxX + 20.0) - (index * ((specs.maxX + 20.0) / 20.0))), y: (index * ((specs.maxY + 20.0) / 20.0)) - 20.0)
//                    withAnimation(.linear(duration: 50.0 * (1.0 - (index / 20.0)))) {
//                        pos = CGPoint(x: -20.0, y: specs.maxY + 20.0)
//                    } completion: {
//                        pos = CGPoint(x: specs.maxX + 20.0, y: -20.0)
//                        withAnimation(.linear(duration: 50.0).repeatForever(autoreverses: false)) {
//                            pos = CGPoint(x: -20.0, y: specs.maxY + 20.0)
//                        }
//                    }
//                }
        }
    }
}

#Preview {
    return GeometryReader { geo in
        LineOfSuits(index: 0)
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
