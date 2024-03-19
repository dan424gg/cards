//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @State var animating: Bool = false
    @State var counter: Int = 0
    @State var cardToPullBack: Int = -1
    @State var inReverse: Bool = false
    @State var nums: [Int] = Array(0...9)
    @State var newPile: [Int] = []
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(nums, id: \.self) { i in
                AnimatingCardView(cardToPullBack: $cardToPullBack, counter: $counter, inReverse: $inReverse, newPile: $newPile, index: i)
            }
        }
        .onAppear {
            counter = nums.count + 1
        }
        .onReceive(timer, perform: { _ in
            if counter >= -10 {
                counter -= 1
            } else {
                counter = nums.count + 10
            }
        })
    }
    
    struct AnimatingCardView: View {
        @Binding var cardToPullBack: Int
        @Binding var counter: Int
        @Binding var inReverse: Bool
        @Binding var newPile: [Int]
        
        @State var offset: CGSize = .zero
        @State var rotation: Angle = .zero
        
        var index: Int
        
        var body: some View {
            CardView(cardItem: CardItem(id: 0), cardIsDisabled: .constant(true), backside: true)
                .onChange(of: counter, {
                    if counter == index {
//                        if index % 2 == 0 {
                            withAnimation(.easeInOut) {
//                                offset = CGSize(width: 100 * (Double(index) / 52.0), height: -300 * (Double(index) / 52.0))
                                rotation = Angle(degrees: 360  * (Double(index) / 10.0))
                            }
//                        } else {
//                            withAnimation(.easeInOut) {
////                                offset = CGSize(width: -100 * (Double(index) / 52.0), height: -300 * (Double(index) / 52.0))
//                                rotation = Angle(degrees: -75  * (Double(index) / 52.0))
//                            }
//                        }
                    }
                    if counter == (-10) {
                        withAnimation(.easeInOut) {
                            offset = .zero
                            rotation = .zero
                        }
                    }
                })
                .rotationEffect(rotation)
                .offset(offset)
        }
    }
}

#Preview {
    let deviceSpecs = DeviceSpecs()
    
    return GeometryReader { geo in
        SwiftUIView()
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
