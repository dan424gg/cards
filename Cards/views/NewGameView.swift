//
//  NewGameView.swift
//  Cards
//
//  Created by Daniel Wells on 3/10/24.
//

import SwiftUI

struct NewGameView: View {
    @Binding var introView: IntroViewType
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var notValid: Bool = true
    @State var fullName: String = ""
    @State var size: CGSize = .zero

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
//                .fill(.thinMaterial)
                .fill(Color.theme.primary)
                .frame(width: 300, height: 300)
            
            VStack {
                Text("New Game")
                    .font(.custom("LuckiestGuy-Regular", size: 40))
                    .foregroundStyle(Color.theme.white)
                
                CustomTextField(textFieldHint: "Name", value: $fullName)
                
                Button {
                    endTextEditing()
                    
                    Task {
                        firebaseHelper.reinitialize()
                        await firebaseHelper.startGameCollection(fullName: fullName)
                        withAnimation(.smooth(duration: 0.3)) {
                            introView = .loadingScreen
                        }
                    }
                } label: {
                    Text("Submit")
                        .padding()
                        .foregroundStyle(Color.white)
                        .font(.custom("LuckiestGuy-Regular", size: 25))
                        .offset(y: 2.2)
                        .frame(width: 150)
                }
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
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .ignoresSafeArea()
}
