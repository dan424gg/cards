//
//  GameView.swift
//  Cards
//
//  Created by Daniel Wells on 11/7/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    
    var body: some View {
        ZStack {
            VStack {
                Text("Cribbage")
                    .font(.largeTitle)
                    .padding()
                Divider()
                    .frame(width: 300)
                Spacer()
                    .frame(height: 75)
                CircleShape()
                    .stroke(Color.gray.opacity(0.5))
                    .aspectRatio(1.35, contentMode: .fit)
                Spacer()
            }
            Cribbage().offset(y: 195)
        }
    }
}

struct CircleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let r = rect.height / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: r,
                        startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: false)
        return path
    }
}

#Preview {
    GameView()
        .environmentObject(FirebaseHelper())
}
