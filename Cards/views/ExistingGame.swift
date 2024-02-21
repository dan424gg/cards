//
//  ExistingGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import SwiftUISnackbar

struct ExistingGame: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @FocusState private var isFocused: Bool
    @State private var notValidGroupId: Bool = true
    @State private var notValidFullName: Bool = true
    @State private var groupId: String = ""
    @State private var fullName: String = ""
    
    @State var gameName: String = ""

    
    private let groupIdFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        return formatter
        }()
    
    var body: some View {
        VStack {
            Text("Please enter a Group ID and your name!")
                .font(.title2)
            TextField(
                "Group ID",
                text: $groupId
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .border(.blue)
            
            TextField(
                "Full Name",
                text: $fullName
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .border(.blue)
            
            Button("Submit") {
                sheetCoordinator.showSheet(.loadingScreen)
            }
            .onTapGesture {
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
        .multilineTextAlignment(.center)
    }
}

struct ExistingGame_Previews: PreviewProvider {
    static var previews: some View {
        ExistingGame(gameName: "Cribbage")
            .environmentObject(FirebaseHelper())
    }
}
