//
//  SettingsView.swift
//  Cards
//
//  Created by Daniel Wells on 5/3/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @Binding var introView: IntroViewType
    @AppStorage(AppStorageConstants.theme) var theme: ColorTheme = .classic
    @AppStorage(AppStorageConstants.filter) var filter: Bool = false
    @State var hack: Int = 0
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                CText("Settings", size: 40)
                    .font(.custom("LuckiestGuy-Regular", size: 40))
                
                HStack {
                    CText("Theme")
                    Spacer()
                    Menu {
                        Picker("theme", selection: $theme) {
                            ForEach(ColorTheme.allCases, id: \.self) { theme in
                                Text(theme.id)
                            }
                        }
                        .id(hack)
                        .onChange(of: theme, {
                            firebaseHelper.logAnalytics(.theme_picked, ["theme": theme.id])
                            withAnimation {
                                hack += 1
                            }
                        })
                    } label: {
                        CText(theme.id)
                            .foregroundStyle(specs.theme.colorWay.secondary)
                    }
                }
                .padding()
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
                
                Toggle(isOn: $filter) {
                    CText("Apply Filter")
                }
                .tint(specs.theme.colorWay.secondary)
                .padding()
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
                                
                HStack {
                    CText("Privacy Policy", size: Int(determineFont("Privacy Policy", Int((specs.maxX * 0.8) - 60.0), 24)))
                        .foregroundStyle(specs.theme.colorWay.secondary)
                    Image(systemName: "link")
                        .fontWeight(.heavy)
                        .imageScale(.large)
                        .foregroundStyle(specs.theme.colorWay.secondary)
                }
                .padding()
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                }
                .onTapGesture {
                    if let url = URL(string: "https://cards-8e688.web.app/") {
                        openURL(url)
                    }
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
        .onTapGesture {
            // allow for tap to close to work
        }
    }
}

#Preview {
    GeometryReader { geo in
        SettingsView(introView: .constant(.settings))
            .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
    }
    .ignoresSafeArea()
    .background {
        DeviceSpecs().theme.colorWay.background
    }
}
