//
//  StatusDot.swift
//  Cards
//
//  Created by Daniel Wells on 10/31/23.
//

import SwiftUI

struct StatusDot: View {
    // This might have to be a binding somehow if when firebaseHelper changes, it doesn't update the value too
    var is_ready: Bool = true
    
    var body: some View {
        if is_ready {
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
    StatusDot(is_ready: true)
}
