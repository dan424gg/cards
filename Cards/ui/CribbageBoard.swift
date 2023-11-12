//
//  CribbageBoard.swift
//  Cards
//
//  Created by Daniel Wells on 11/11/23.
//

import SwiftUI

struct CribbageBoard: View {
    var teamOnePoints = 0
    var teamTwoPoints = 0
    
    var body: some View {
        ZStack {
            Track()
                .stroke(.red)
                .frame(width: 300, height: 300)

            Track(adjustment: 20)
                .stroke(.blue)
                .frame(width: 300, height: 300)

            Track(adjustment: 40)
                .stroke(.green)
                .frame(width: 300, height: 300)
        }
        .offset(x:-30)
    }
}

struct Track: Shape {
    var adjustment: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + adjustment))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + adjustment))
        path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - adjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: (rect.maxX / 5), y: rect.maxY - adjustment))
        path.addArc(center: CGPoint(x: (rect.maxX / 5), y: (rect.midY / 2) + rect.midY), radius: (rect.midY / 2) - adjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + adjustment))
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 15 + adjustment))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 15 + adjustment))
        path.addArc(center: CGPoint(x: rect.maxX, y: rect.midY), radius: rect.midY - 15 - adjustment, startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: (rect.maxX / 5), y: rect.maxY - 15 - adjustment))
        path.addArc(center: CGPoint(x: (rect.maxX / 5), y: (rect.midY / 2) + rect.midY), radius: (rect.midY / 2) - 15 - adjustment, startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + 15 + adjustment))
        
        return path
    }
}

#Preview {
    CribbageBoard()
}
