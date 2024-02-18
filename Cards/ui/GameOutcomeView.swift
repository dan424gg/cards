//
//  GameOutcomeView.swift
//  Cards
//
//  Created by Daniel Wells on 2/18/24.
//

import SwiftUI

struct GameOutcomeView: View {
    @EnvironmentObject private var firebaseHelper: FirebaseHelper
    @Binding var outcome: GameOutcome
    @State var endGameOpacity: Double = 1.0

    var body: some View {
        ZStack {
            switch (outcome) {
                case .win:
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .ignoresSafeArea(.all)
                        Text("You win!")
                            .foregroundStyle(.green)
                            .font(.largeTitle)
                    }
                    .zIndex(0)
                    .transition(.opacity)
                case .lose:
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .ignoresSafeArea(.all)
                        Text("You lose!")
                            .foregroundStyle(.red)
                            .font(.largeTitle)
                    }
                    .zIndex(0)
                    .transition(.opacity)
                case .undetermined:
                    EmptyView()
            }
        }
        .opacity(endGameOpacity)
        .animation(.easeInOut.speed(0.5).delay(0.3), value: outcome)
        .onChange(of: outcome, {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut.speed(0.3).delay(0.3)) {
                    endGameOpacity = 0.0
                }
            }
        })
    }
}

#Preview {
    GameOutcomeView(outcome: .constant(.lose))
        .environmentObject(FirebaseHelper())
}
