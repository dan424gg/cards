//
//  PickerItems.swift
//  Cards
//
//  Created by Daniel Wells on 1/14/24.
//

import SwiftUI

struct PickerItems: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @Binding var teamColor: String
    @Binding var colorsAvailable: [String]
    @State var listOfColors: [String] = ["Red", "Yellow", "Blue", "Orange"]

    var body: some View {
        ForEach(listOfColors, id: \.self) { colorString in
            Button(colorString) {
                teamColor = colorString
                Task {
                    await firebaseHelper.updateTeam(["color": colorString])
                }
            }
            .disabled(
                colorsAvailable.contains(colorString)
            )
        }
    }
}

#Preview {
    PickerItems(teamColor: .constant("Red"), colorsAvailable: .constant(["Red", "Yellow", "Blue", "Orange"]))
        .environmentObject(FirebaseHelper())
}
