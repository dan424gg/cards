//
//  TurnThreeView.swift
//  Cards
//
//  Created by Daniel Wells on 2/7/24.
//

import SwiftUI

struct TurnThreeView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    
    var body: some View {
        Text("Turn Three!")
    }
}

#Preview {
    TurnThreeView()
        .environmentObject(FirebaseHelper())
}
