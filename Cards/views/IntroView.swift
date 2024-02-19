//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

struct IntroView: View {
    var heartImage: Image = Image(systemName: "suit.heart")
    var spadeImage: Image = Image(systemName: "suit.spade")
    var diamondImage: Image = Image(systemName: "suit.diamond")
    var clubImage: Image = Image(systemName: "suit.club")
    
    @State var offset: CGFloat = -50.0
    @State var heartPos: CGPoint = CGPoint(x: 0, y: 0)
    
    var array: [Int] = Array(0...11)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(array, id: \.self) { i in
                    
                    switch (i % 4) {
                        case 0:
                            SuitImage(suit: "diamond", index: CGFloat(i), geo: geo)
                        case 1:
                            SuitImage(suit: "club", index: CGFloat(i), geo: geo)
                        case 2:
                            SuitImage(suit: "heart", index: CGFloat(i), geo: geo)
                        case 3:
                            SuitImage(suit: "spade", index: CGFloat(i), geo: geo)
                        default:
                            EmptyView()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .frame(width: 250, height: 250)
        .border(.black)
    }
}

struct SuitImage: View {
    var suit: String
    var index: CGFloat
    var geo: GeometryProxy
    
    @State var pos = CGPoint(x: 0.0, y: 0.0)
    
    var body: some View {
        GeometryReader { geoProxy in
            Image(systemName: "suit.\(suit)")
                .foregroundColor(suit == "spade" || suit == "club" ? .black : .red)
                .opacity(0.3)
                .position(pos)
                .onAppear {
                    let a = geo.frame(in: .local).maxX + 20.0
                    let b = geo.frame(in: .local).maxY + 20.0
                    let c: CGFloat = sqrt((a*a) + (b*b))
                    
                    pos = CGPoint(x: a - (index * (a / CGFloat(12))), y: (index * (b / CGFloat(12))) - 20.0)
//                    withAnimation(.linear(duration: 15.0 * (1 - (index / 12)))) {
//                        pos = CGPoint(x: -20.0, y: b)
//                    } completion: {
//                        pos = CGPoint(x: a, y: -20.0)
//                        withAnimation(.linear(duration: 15.0).repeatForever(autoreverses: false)) {
//                            pos = CGPoint(x: -20.0, y: b)
//                        }
//                    }
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
//    SuitImage(suit: "club")
    IntroView()
}
