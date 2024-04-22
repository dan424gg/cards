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
            VStack(spacing: 20) {
                Text("New Game")
                    .font(.custom("LuckiestGuy-Regular", size: 40))
                    .baselineOffset(-10)
                    .foregroundStyle(Color.theme.white)
                    .frame(height: 40)
                
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .font(.custom("LuckiestGuy-Regular", size: 24))
                        .baselineOffset(-5)
                        .foregroundStyle(Color.theme.primary)
                        .background(Color.theme.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20.0)
    //                .fill(.thinMaterial)
                    .fill(Color.theme.primary)
                    .frame(width: 300)
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
