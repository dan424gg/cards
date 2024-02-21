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
    @State private var fullName: String = ""
    @FocusState private var focusedField: FocusField?
    
    @State var gameName: String = "test"
    
    var body: some View {
        VStack {
            Text("Please enter your name (or anything)!")
                .font(.title3)
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
            .disabled(fullName == "")
        }
        .multilineTextAlignment(.center)
//        .padding([.leading, .trailing], 48)
    }
}

struct NewGame_Previews: PreviewProvider {
    static var previews: some View {
        NewGame()
            .environmentObject(FirebaseHelper())
    }
}
