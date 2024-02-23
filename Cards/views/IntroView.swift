//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    var array: [Int] = Array(0...19)
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
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
                ZStack {
                    ForEach (Array(1...9), id: \.self) { y in
                        ZStack {
                            ForEach(array, id: \.self) { i in
                                switch ((i + y) % 4) {
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
                        .offset(y: CGFloat(-85 * y))
                        
                        ZStack {
                            ForEach(array, id: \.self) { i in
                                switch ((i + y) % 4) {
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
                        .offset(y: CGFloat(85 * y))
                    }
                }
                
                Text("CARDS")
                    .font(.system(size: 75))
                    .shadow(color: .white, radius: 5)
                    .shadow(color: .white, radius: 5)
                    .shadow(color: .white, radius: 5)
                    .shadow(color: .white, radius: 5)
                    .shadow(color: .white, radius: 5)
                    .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).height * 0.25)
                
                VStack {
                    Button("New Game") {
                        sheetCoordinator.showSheet(.newGame)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    
                    Button("Join Game") {
                        sheetCoordinator.showSheet(.existingGame)
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
            .sheetDisplayer(coordinator: sheetCoordinator)
        }
        .ignoresSafeArea()
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
                .foregroundColor(suit == "spade" || suit == "club" ? .black.opacity(0.2) : .red.opacity(0.2))
                .position(pos)
                .onAppear {
                    let a = geo.frame(in: .local).maxX + 20.0
                    let b = geo.frame(in: .local).maxY + 20.0
                    
                    pos = CGPoint(x: a - (index * (a / CGFloat(20))), y: (index * (b / CGFloat(20))) - 20.0)
                    withAnimation(.linear(duration: 100.0 * (1 - (index / 20)))) {
                        pos = CGPoint(x: -20.0, y: b)
                    } completion: {
                        pos = CGPoint(x: a, y: -20.0)
                        withAnimation(.linear(duration: 100.0).repeatForever(autoreverses: false)) {
                            pos = CGPoint(x: -20.0, y: b)
                        }
                    }
                }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    IntroView()
        .environmentObject(FirebaseHelper())
}
