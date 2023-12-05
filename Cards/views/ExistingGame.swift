//
//  ExistingGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import SwiftUISnackbar

struct ExistingGame: View {
    var gameName: String
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @State private var notValidGroupId: Bool = true
    @State private var groupId: Int = 0
    @State private var fullName: String = ""
    
    @FocusState private var isFocused: Bool
    
    private let groupIdFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.zeroSymbol = ""
            return formatter
        }()
    
    var body: some View {
        VStack {
            Text("Please enter a Group ID, and your name!")
                .font(.title2)
            TextField(
                "Group ID",
                value: $groupId,
                formatter: groupIdFormatter
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .border(.blue)
            .focused($isFocused)
            .onChange(of: isFocused) {
                if isFocused {
                    // ensure snackbar isn't being shown
                } else {
                    // determine validity of groupid
                    Task {
                        if await firebaseHelper.checkValidId(id: groupId) {
                            notValidGroupId = false
                        } else {
                            notValidGroupId = true
                            firebaseHelper.sendError(e: "Group ID is not valid!")
                        }
                    }
                }
            }
            
            TextField(
                "Full Name",
                text: $fullName
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .border(.blue)
            
            NavigationLink {
                LoadingScreen(groupId: groupId, fullName: fullName, gameName: gameName)
            } label: {
                Text("Submit")
                    .buttonStyle(.borderedProminent)
            }
            .disabled(notValidGroupId || fullName == "")

        }
        .multilineTextAlignment(.center)
        .padding([.leading, .trailing], 48)
        .snackbar(isShowing: $firebaseHelper.showError, 
                  title: "Not Ready",
                  text: firebaseHelper.error,
                  style: .error,
                  actionText: "dismiss",
                  dismissOnTap: false,
                  dismissAfter: nil,
                  action: { firebaseHelper.showError = false; firebaseHelper.error = "" }
        )
        .snackbar(isShowing: $firebaseHelper.showWarning,
                  title: "Not Ready",
                  text: firebaseHelper.warning,
                  style: .warning,
                  actionText: "dismiss",
                  dismissOnTap: false,
                  dismissAfter: nil,
                  action: { firebaseHelper.showWarning = false; firebaseHelper.warning = "" }
        )
    }
}

struct ExistingGame_Previews: PreviewProvider {
    static var previews: some View {
        ExistingGame(gameName: "Cribbage")
            .environmentObject(FirebaseHelper())
    }
}
