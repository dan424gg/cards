//
//  NewGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/15/23.
//

import SwiftUI

struct NewGame: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @State var fullName: String = ""
    @FocusState private var focusedField: FocusField?
    @State private var size: CGSize = .zero
    @State var gameName: String = "test"
    @State var notValid: Bool = true
    
    var body: some View {
        VStack {
            Text("New Game")
                .font(.title)
            
            CustomTextField(textFieldHint: "Name", value: $fullName)
            
            Button("Submit", systemImage: notValid ? "x.circle" : "checkmark.circle", action: {
                sheetCoordinator.showSheet(.loadingScreen)
                Task {
                    await firebaseHelper.startGameCollection(fullName: fullName, gameName: gameName)
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
                if fullName.isEmpty || fullName == "" {
                    notValid = true
                } else {
                    notValid = false
                }
            }
        })
        .position(x: size.width / 2, y: size.height / 2)
        .getSize(onChange: {
            if size == .zero {
                size = $0
            }
        })
        .onTapGesture {
            endTextEditing()
        }
    }
}

#Preview {
    return GeometryReader { geo in
        NewGame(gameName: "Cribbage")
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

