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

//    @Binding var isRunning: Bool
//    @Binding var isReversing: Bool
    
    @State var pos = CGPoint(x: 0.0, y: 0.0)
    @State var pos2 = CGPoint(x: 0.0, y: 0.0)
    @State var size: CGSize = .zero
    @State var duration: Double = 80.0
    
    var body: some View {
        ZStack {
//            VStack(spacing: 25) {
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
    }
    
    struct SuitImage: View {
        @EnvironmentObject var specs: DeviceSpecs
        
        var suit: String
        var index: CGFloat
        
        @State var pos = CGPoint(x: 0.0, y: 0.0)
        
        var body: some View {
            Image(systemName: "suit.\(suit)")
                .foregroundColor(suit == "spade" || suit == "club" ? .black.opacity(0.3) : .red.opacity(0.3))
                .position(pos)
                .onAppear {
                    pos = CGPoint(x: (specs.maxX - (index * (specs.maxX / 20.0))) + 20.0, y: (index * (specs.maxY / 20.0)))
                    withAnimation(.linear(duration: 50.0 * (1.0 - (index / 20.0)))) {
                        pos = CGPoint(x: -20.0, y: specs.maxY + 20.0)
                    } completion: {
                        pos = CGPoint(x: specs.maxX + 20.0, y: -20.0)
                        withAnimation(.linear(duration: 50.0).repeatForever(autoreverses: false)) {
                            pos = CGPoint(x: -20.0, y: specs.maxY + 20.0)
                        }
                    }
                }
        }
    }
    
    struct LineOfSuitsModifer: Animatable {
        @Binding var pos: CGPoint
        @Binding var isRunning: Bool
        @Binding var isReversing: Bool
        
        var animatableData: CGPoint {
            get { pos }
            set { pos = newValue }
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
//    .ignoresSafeArea()
}
