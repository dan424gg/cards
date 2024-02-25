//
//  IntroView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    
    var body: some View {
        ZStack {
            Text("CARDS")
                .font(.system(size: 75))
                .shadow(color: .white, radius: 5)
                .shadow(color: .white, radius: 5)
                .shadow(color: .white, radius: 5)
                .shadow(color: .white, radius: 5)
                .shadow(color: .white, radius: 5)
                .position(x: specs.maxX / 2, y: specs.maxY * 0.25)

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
        .background {
            ForEach(Array(0...20), id: \.self) { i in
                SuitLine(index: i, specs: specs)
                    .offset(y: CGFloat(-85 * i))
            }
            .position(x: specs.maxX / 2, y: specs.maxY * 1.5)
        }
        .sheetDisplayer(coordinator: sheetCoordinator)
    }
    
    struct SuitLine: View {
        var index: Int
        var specs: DeviceSpecs
        var array: [Int] = Array(0...19)

        @State var pos = CGPoint(x: 0.0, y: 0.0)
        @State var pos2 = CGPoint(x: 0.0, y: 0.0)
        @State var size: CGSize = .zero
        @State var duration: Double = 80.0
        
        var body: some View {
            ZStack {
                VStack(spacing: 25) {
                    ForEach(array, id: \.self) { i in
                        switch ((i + index) % 4) {
                            case 0:
                                SuitImage(suit: "diamond")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            case 1:
                                SuitImage(suit: "club")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            case 2:
                                SuitImage(suit: "heart")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            case 3:
                                SuitImage(suit: "spade")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            default:
                                EmptyView()
                        }
                    }
                }
                .zIndex(0)
                .position(pos)
                .offset(y: size.height / 2)
                .getSize(onChange: {
                    if size == .zero {
                        size = $0
                    }
                })
                .onAppear {
                    pos = CGPoint(x: specs.maxX, y: 0.0)
                    withAnimation(.linear(duration: duration / 2)) {
                        pos = CGPoint(x: 0.0, y: specs.maxY)
                    } completion: {
                        pos = CGPoint(x: 2 * specs.maxX, y: -specs.maxY)
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            pos = CGPoint(x: 0.0, y: specs.maxY)
                        }
                    }
                }
                
                VStack(spacing: 25) {
                    ForEach(array, id: \.self) { i in
                        switch ((i + index + 1) % 4) {
                            case 0:
                                SuitImage(suit: "diamond")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            case 1:
                                SuitImage(suit: "club")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            case 2:
                                SuitImage(suit: "heart")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            case 3:
                                SuitImage(suit: "spade")
                                    .offset(x: Double(i) * (specs.maxX / -20))
                            default:
                                EmptyView()
                        }
                    }
                }
                .zIndex(0)
                .position(pos2)
                .offset(y: size.height / 2)
                .getSize(onChange: {
                    if size == .zero {
                        size = $0
                    }
                })
                .onAppear {
                    pos2 = CGPoint(x: 2 * specs.maxX, y: -specs.maxY)
                    withAnimation(.linear(duration: duration)) {
                        pos2 = CGPoint(x: 0.0, y: specs.maxY)
                    } completion: {
                        pos2 = CGPoint(x: 2 * specs.maxX, y: -specs.maxY)
                        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                            pos2 = CGPoint(x: 0.0, y: specs.maxY)
                        }
                    }
                }
            }
        }
    }
    
    struct SuitImage: View {
        var suit: String
        
        var body: some View {
            Image(systemName: "suit.\(suit)")
                .foregroundColor(suit == "spade" || suit == "club" ? .black.opacity(0.3) : .red.opacity(0.3))
        }
    }
}

#Preview {
    return GeometryReader { geo in
        IntroView()
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
