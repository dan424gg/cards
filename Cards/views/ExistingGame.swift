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
    @State private var notValid: Bool = true
    @State var groupId: String = ""
    @State var fullName: String = ""

    @State var gameName: String = ""
    @State var size: CGSize = .zero
    
    var body: some View {
        VStack {
            Text("Join Game")
                .font(.title)

            CustomTextField(textFieldHint: "Group ID", value: $groupId)
            CustomTextField(textFieldHint: "Name", value: $fullName)
            
            Button("Submit", systemImage: notValid ? "x.circle" : "checkmark.circle", action: {
                sheetCoordinator.showSheet(.loadingScreen)
                Task {
                    await firebaseHelper.joinGameCollection(fullName: fullName, id: groupId)
                }
            })
            .labelStyle(.iconOnly)
            .symbolRenderingMode(.palette)
            .foregroundStyle(notValid ? .gray.opacity(0.5) : .green)
            .disabled(notValid)
            .font(.system(size: 35))
        }
        .onChange(of: [groupId, fullName], {
            Task {
                if groupId.isEmpty || groupId == "" || fullName.isEmpty || fullName == "" {
                    withAnimation {
                        notValid = true
                    }
                    firebaseHelper.sendWarning(w: "Group ID is not valid!")
                } else if (await !firebaseHelper.checkValidId(id: groupId)) {
                    withAnimation {
                        notValid = true
                    }
                    firebaseHelper.sendWarning(w: "Group ID is not valid!")
                } else {
                    withAnimation {
                        notValid = false
                    }
                    firebaseHelper.resetWarning()
                }
            }
        })
//        .onChange(of: , {
//            if fullName == "" {
//                notValid = true
//            } else {
//                notValid = false
//            }
//        })
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
