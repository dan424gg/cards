//
//  ExistingGame.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import SwiftUISnackbar

struct ExistingGame: View {
    var name: String
    @State private var notValid: Bool = true
    @State private var showSnackbar = false
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
                    showSnackbar = false
                } else {
                    // determine validity of groupid
                    Task {
                        if await FirebaseHelper().checkValidId(id: groupId) {
                            notValid = false
                        } else {
                            showSnackbar = true
                            notValid = true
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
                LoadingScreen(groupId: String(groupId), fullName: fullName, gameName: name)
            } label: {
                Text("Submit")
                    .buttonStyle(.borderedProminent)
            }
            .disabled(notValid)
        }
        .multilineTextAlignment(.center)
        .padding([.leading, .trailing], 48)
        .snackbar(isShowing: $showSnackbar, title: "Group ID", text: "Group ID is not valid!", style: .error)
    }
}

struct ExistingGame_Previews: PreviewProvider {
    static var previews: some View {
        ExistingGame(name: "Cribbage")
            .environmentObject(FirebaseHelper())
    }
}
