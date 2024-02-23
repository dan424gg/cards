//
//  ExistingGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import SwiftUISnackbar

struct ExistingGame: View {
    @EnvironmentObject var specs: DeviceSpecs
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @FocusState private var isFocused: Bool
    @State private var notValidGroupId: Bool = true
    @State private var notValidFullName: Bool = true
    @State private var groupId: String = ""
    @State private var fullName: String = ""

    @State var gameName: String = ""
    @State var size: CGSize = .zero
    
    var body: some View {
        VStack {
            Text("Join Game")
                .foregroundStyle(.black)
                .font(.title2)

            CustomTextField(textFieldHint: "Group ID")
            CustomTextField(textFieldHint: "Name")
            
            Button("Submit") {
                sheetCoordinator.showSheet(.loadingScreen)
                Task {
                    await firebaseHelper.startGameCollection(fullName: fullName, gameName: gameName)
                }
            }
            .disabled(notValidGroupId || fullName == "")
        }
        .onChange(of: groupId, {
            Task {
                if groupId.isEmpty || groupId == "" {
                    notValidGroupId = true
                    firebaseHelper.sendWarning(w: "Group ID is not valid!")
                } else if (await !firebaseHelper.checkValidId(id: groupId)) {
                    notValidGroupId = true
                    firebaseHelper.sendWarning(w: "Group ID is not valid!")
                } else {
                    notValidGroupId = false
                    firebaseHelper.resetWarning()
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
        ExistingGame(gameName: "Cribbage")
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
