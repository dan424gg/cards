//
//  NewGameView.swift
//  Cards
//
//  Created by Daniel Wells on 3/10/24.
//

import SwiftUI

struct NewGameView: View {
    @Binding var introView: IntroViewType
    @EnvironmentObject var gameHelper: GameHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var notValid: Bool = true
    @State var fullName: String = ""
    @State var size: CGSize = .zero

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                CText("New Game", size: 40)
                    .foregroundStyle(specs.theme.colorWay.textColor)
                    .frame(height: 40)
                
                CustomTextField(textFieldHint: "Name", value: $fullName)
                
                CustomButton(name: "Submit", submitFunction: {
                    endTextEditing()
                    
                    Task {
                        gameHelper.reinitialize()
                        await gameHelper.startGameCollection(fullName: fullName)
                        withAnimation(.smooth(duration: 0.3)) {
                            introView = .loadingScreen
                        }
                    }
                })
            }
            .padding()
            .frame(width: specs.maxX * 0.8)
            .background {
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(specs.theme.colorWay.primary)
                    .shadow(radius: 10)
            }
            .onChange(of: fullName, {
                withAnimation {
                    if fullName.isEmpty {
                        notValid = true
                    } else {
                        notValid = false
                    }
                }
            })

        }
        .onTapGesture {
            endTextEditing()
        }
        .overlay(alignment: .topTrailing) {
            ImageButton(image: Image(systemName: "x.circle.fill"), submitFunction: {
                withAnimation(.snappy.speed(1.0)) {
                    introView = .nothing
                    endTextEditing()
                }
            })
            .offset(x: 20.0, y: -20.0)
            .font(.system(size: 45, weight: .heavy))
            .foregroundStyle(specs.theme.colorWay.primary, specs.theme.colorWay.secondary)
        }
    }
    
    
}

#Preview {
    return GeometryReader { geo in
        NewGameView(introView: .constant(.nothing))
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
            .background {
                DeviceSpecs().theme.colorWay.background
            }
    }
    .ignoresSafeArea()
}
