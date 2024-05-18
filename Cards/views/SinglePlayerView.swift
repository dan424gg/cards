//
//  SinglePlayerView.swift
//  Cards
//
//  Created by Daniel Wells on 5/17/24.
//

import SwiftUI

struct SinglePlayerView: View {
    @Environment(GameHelper.self) var gameHelper
    @Environment(DeviceSpecs.self) var specs
    @Binding var introView: IntroViewType
    
    @State var name: String = ""
    @State var numberOfBots: Int = 1
    @State var color: Color = .blue
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                CText("Single Player", size: 40)
                    .font(.custom("LuckiestGuy-Regular", size: 40))
                
                HStack {
                    CText("Game")
                    Spacer()
                    GamePicker(color: specs.theme.colorWay.secondary)
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
                
                HStack {
                    CText("Name")
                    Spacer()
                    CustomTextField(textFieldHint: "Name", widthMultiplier: 0.3, alignment: .trailing, value: $name)
                        .textFieldStyle(ClearTextFieldBorder())
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
                
                HStack {
                    CText("number of bots")
                    Spacer()
                    Menu {
                        Picker("Bots", selection: $numberOfBots, content: {
                            ForEach([1,2,3], id: \.self) { num in
                                Text("\(num)")
                            }
                        })
                    } label: {
                        CText("\(numberOfBots)")
                            .foregroundStyle(specs.theme.colorWay.secondary)
                            .underline()
                    }
                    
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
                
                HStack {
                    CText("team color")
                    Spacer()
                    TeamColorPicker()
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(specs.theme.colorWay.primary)
                    .shadow(radius: 10)
            }
            .frame(width: specs.maxX * 0.8)
            .overlay(alignment: .topTrailing) {
                ImageButton(image: Image(systemName: "x.circle.fill"), submitFunction: {
                    withAnimation(.snappy.speed(1.0)) {
                        introView = .nothing
                    }
                })
                .offset(x: 20.0, y: -20.0)
                .font(.system(size: 45, weight: .heavy))
                .foregroundStyle(specs.theme.colorWay.primary, specs.theme.colorWay.secondary)
            }
        }
    }
}

#Preview {
    GeometryReader { geo in
        SinglePlayerView(introView: .constant(.nothing))
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            .environment({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environment(GameHelper())
    }
    .ignoresSafeArea()
    .background {
        DeviceSpecs().theme.colorWay.background
    }
}
