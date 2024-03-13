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
            Color.launch.background
                .ignoresSafeArea()
            Text("This is a placeholder and a test")
                .font(.system(size: 24))
            ProgressView()
                .offset(y: 100)
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in
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
