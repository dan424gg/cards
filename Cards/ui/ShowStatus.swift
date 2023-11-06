//
//  StatusDot.swift
//  Cards
//
//  Created by Daniel Wells on 10/31/23.
//

import SwiftUI

struct ShowStatus: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    // This might have to be a binding somehow if when firebaseHelper changes, it doesn't update the value too
//    @Binding var is_ready: Bool
    
    var body: some View {
        if firebaseHelper.playerInfo?.is_ready {
            Circle()
                .fill(.green)
                .frame(width: 10, height: 10)
        } else {
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)
        }
    }
}

#Preview {
    ShowStatus()
        .environmentObject(FirebaseHelper())
}
