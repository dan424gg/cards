//
//  LaunchView.swift
//  Cards
//
//  Created by Daniel Wells on 3/13/24.
//

import SwiftUI
import Combine

struct LaunchView: View {
    @Binding var showLaunch: Bool
    @State var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.white
            Image("Cards")
                .resizable()
                .aspectRatio(332/85, contentMode: .fit)
                .frame(width: 200)
        }
        .ignoresSafeArea()
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: { _ in
                withAnimation(.snappy(duration: 0.3)) {
                    showLaunch = false
                }
            })
        }
    }
}

#Preview {
    LaunchView(showLaunch: .constant(false))
}
