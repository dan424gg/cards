//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {    
    var body: some View {
        VStack {
            Text("hi")
        }
    }
}

#Preview {
    SwiftUIView()
        .environmentObject(FirebaseHelper())
}
