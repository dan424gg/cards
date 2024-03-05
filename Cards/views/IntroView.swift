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
    @StateObject var sheetCoordinator: SheetCoordinator<SheetType>
    @State var scale: Double = 1.0
            
    var body: some View {
        ZStack {
            Text("CARDS")
                .font(.system(size: 100, weight: .thin))
                .foregroundStyle(.black)
                .position(x: specs.maxX / 2, y: specs.maxY * 0.25)
            
//            Image("Cards")
//                .scaleEffect(0.5)
//                .position(x: specs.maxX / 2, y: specs.maxY * 0.33)

            VStack(spacing: 10) {
                Button {
                    sheetCoordinator.showSheet(.gameSetUp(type: .existingGame))
                } label: {
                    Text("Join Game")
                        .foregroundStyle(.black)
                        .font(.system(size: 15, weight: .thin))
                        .frame(width: specs.maxX * 0.66, height: 33)
                }
                .background(.thinMaterial)
                .tint(Color("OffWhite").opacity(0.7))
                .buttonStyle(.bordered)
                
                Button {
                    sheetCoordinator.showSheet(.gameSetUp(type: .newGame))
                } label: {
                    Text("New Game")
                        .foregroundStyle(.black)
                        .font(.system(size: 15, weight: .thin))
                        .frame(width: specs.maxX * 0.66, height: 33)
                }
                .background(.thinMaterial)
                .tint(Color("OffWhite").opacity(0.7))
                .buttonStyle(.bordered)
            }
            .position(x: specs.maxX / 2, y: specs.maxY * 0.75)
        }
//        .background {
//            Color("OffWhite")
//                .opacity(0.07)
//            ForEach(Array(0...20), id: \.self) { i in
//                LineOfSuits(index: i)
//                    .offset(y: CGFloat(-85 * i))
//            }
//            .position(x: specs.maxX / 2, y: specs.maxY * 1.5)
//        }
//        .sheetDisplayer(coordinator: sheetCoordinator)
    }
}

#Preview {
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()

    return GeometryReader { geo in
        IntroView(sheetCoordinator: sheetCoordinator)
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
