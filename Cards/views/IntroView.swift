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
    
    @State var visible: Bool = false
            
    var body: some View {
        ZStack {
            Text("CARDS")
                .font(.system(size: 100, weight: .light))
                .foregroundStyle(.black)
                .position(x: specs.maxX / 2, y: specs.maxY * 0.25)
//                .opacity(0.5)
            
//            Image("Cards")
//                .scaleEffect(0.5)
//                .position(x: specs.maxX / 2, y: specs.maxY * 0.33)

            VStack(spacing: 15) {
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
                    withAnimation {
                        visible.toggle()
                    }
//                    sheetCoordinator.showSheet(.gameSetUp(type: .newGame))
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
        .overlay {
            ZStack {
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Material.ultraThinMaterial)
//            if visible {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 20.0)
//                        .fill(Color("OffWhite").opacity(0.2))
//                        .frame(width: 300, height: 300)
//                        .overlay {
//                            GameSetUpView(setUpType: .newGame)
//                        }
//                }
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(.ultraThinMaterial)
//                .onTapGesture {
//                    withAnimation {
//                        visible.toggle()
//                    }
//                }
//                .blur(radius: 0.3, opaque: false)
//            }
        }
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
