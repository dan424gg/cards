//
//  NewGameView.swift
//  Cards
//
//  Created by Daniel Wells on 3/10/24.
//

import SwiftUI

struct NewGameView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var notValid: Bool = true
    @State var fullName: String = ""
    @State var size: CGSize = .zero

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
                .fill(.white)
                .fill(Color("OffWhite").opacity(0.2))
                .frame(width: 300, height: 300)
            
            VStack {
                Text("New Game")
                    .font(.title2)
                
                CustomTextField(textFieldHint: "Name", value: $fullName)
                
                Button("Submit", systemImage: notValid ? "x.circle" : "checkmark.circle", action: {
                    Task {
                        await firebaseHelper.startGameCollection(fullName: fullName)
                    }
                })
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.palette)
                .foregroundStyle(notValid ? .gray.opacity(0.5) : .green)
                .disabled(notValid)
                .font(.system(size: 35))
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
        NewGameView()
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
