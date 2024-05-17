//
//  LineOfSuits.swift
//  Cards
//
//  Created by Daniel Wells on 2/29/24.
//

import SwiftUI
import UIKit
import Combine

struct LineOfSuits: View {
    @Environment(DeviceSpecs.self) private var specs

    var index: Int
    @State var array: [Int] = []
    @State var pos = CGPoint(x: 0.0, y: 0.0)
    @State var pos2 = CGPoint(x: 0.0, y: 0.0)
    
    var body: some View {
        ZStack {
            ZStack {
                ForEach(array, id: \.self) { i in
                    switch ((i + index) % 4) {
                        case 0:
                            SuitImage(suit: "diamond", index: CGFloat(i), arrayLen: array.count)
                        case 1:
                            SuitImage(suit: "club", index: CGFloat(i), arrayLen: array.count)
                        case 2:
                            SuitImage(suit: "heart", index: CGFloat(i), arrayLen: array.count)
                        case 3:
                            SuitImage(suit: "spade", index: CGFloat(i), arrayLen: array.count)
                        default:
                            EmptyView()
                    }
                }
            }
//            .zIndex(0)
//            .position(pos)
//            .onAppear {
//                let maxX = specs.maxX + 5.0
//                let maxY = specs.maxY + 5.0
//                
//                pos = CGPoint(x: maxX / 2, y: maxY / 2)
//                withAnimation(.linear(duration: duration / 2)) {
//                    pos = CGPoint(x: -maxX / 2, y: maxY * 1.5)
//                } completion: {
//                    pos = CGPoint(x: maxX * 1.5, y: -maxY / 2)
//                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
//                        pos = CGPoint(x: -maxX / 2, y: maxY * 1.5)
//                    }
//                }
//            }
//            
//            ZStack {
//                ForEach(array, id: \.self) { i in
//                    switch ((i + index) % 4) {
//                        case 0:
//                            SuitImage(suit: "diamond", index: CGFloat(i))
//                        case 1:
//                            SuitImage(suit: "club", index: CGFloat(i))
//                        case 2:
//                            SuitImage(suit: "heart", index: CGFloat(i))
//                        case 3:
//                            SuitImage(suit: "spade", index: CGFloat(i))
//                        default:
//                            EmptyView()
//                    }
//                }
//            }
//            .zIndex(0)
//            .position(pos2)
////            .offset(x: -5, y: -5)
//            .onAppear {
//                let maxX = specs.maxX + 5.0
//                let maxY = specs.maxY + 5.0
//                
//                pos2 = CGPoint(x: maxX * 1.5, y: -maxY / 2)
//                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
//                    pos2 = CGPoint(x: -maxX / 2, y: maxY * 1.5)
//                }
//            }
        }
        .onAppear {
            // a^2 + b^2 = c^2: to get the length of the diagonal
            let c: Double = sqrt(((specs.maxX + 20) * (specs.maxX + 20)) + ((specs.maxY + 20) * (specs.maxY + 20)))
            
            // arrayLen to achieve spacing of card suits
            var arrayLen: Int = Int(0.01658 * c)
            
            // updated arrayLen to be a multiple of 4
            let remainder: Int = arrayLen % 4
            arrayLen += (4 - remainder)
            
            array = Array(0..<arrayLen)
        }
    }
    
    struct SuitImage: View {
        var suit: String
        var index: CGFloat
        var arrayLen: Int
        @Environment(DeviceSpecs.self) private var specs
        @State var duration: Double = 100.0
        @State var pos = CGPoint(x: 0.0, y: 0.0)
        
        var body: some View {
            Image(systemName: "suit.\(suit).fill")
                .if(specs.theme.colorWay.id == "CardGameColorWay", {
                    $0.foregroundStyle(suit == "spade" || suit == "club" ? .black.opacity(0.7) : specs.theme.colorWay.primary.opacity(0.7))
                }, else: {
                    $0.foregroundStyle(specs.theme.colorWay.primary.opacity(0.4))
                })
                .scaleEffect(1.2)
                .position(pos)
                .onAppear {
                    let maxX = specs.maxX + 20
                    let maxY = specs.maxY + 20
                    
                    let x = maxX - (index * (maxX / Double(arrayLen)))
                    let y = (index * (maxY / Double(arrayLen))) - 20.0
                    
                    pos = CGPoint(x: x, y: y)
//                    withAnimation(.linear(duration: duration * (1.0 - (index / Double(arrayLen))))) {
//                        pos = CGPoint(x: -20.0, y: maxY)
//                    } completion: {
//                        pos = CGPoint(x: maxX, y: -20.0)
//                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
//                            pos = CGPoint(x: -20.0, y: maxY)
//                        }
//                    }
                }
        }
    }

}

#Preview {
    return GeometryReader { geo in
        LineOfSuits(index: 0)
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .ignoresSafeArea()
}
