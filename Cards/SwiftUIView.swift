//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @State var scale: Double = 0.0
    
    var body: some View {
//        Circle()
//            .frame(width: 200, height: 200)
//            .scaleEffect(scale)
//            .animateForever(autoreverses: true) { scale = 0.5 }
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: 57.0, style: .continuous)
                .stroke(Color("greenForPlayerPlaying"), lineWidth: 25.0)
//                .scaleEffect(scale, anchor: .center)
                .opacity(scale)
                .ignoresSafeArea()
                .onAppear {
                    let baseAnimation = Animation.easeInOut(duration: 2.0)
                    let repeated = baseAnimation.repeatForever(autoreverses: true)
                    
                    withAnimation(repeated) {
                        scale = 0.8
                    }
                }
        }
    }
}

extension View {
    func animateForever(using animation: Animation = .easeInOut(duration: 1), autoreverses: Bool = false, _ action: @escaping () -> Void) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)

        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
