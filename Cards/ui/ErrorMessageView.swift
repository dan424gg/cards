//
//  ErrorMessage.swift
//  Cards
//
//  Created by Daniel Wells on 4/8/24.
//

import SwiftUI

enum ErrorType: Hashable {
    case error, success, none
}

struct Error: Equatable {
    var message: String
    var errorType: ErrorType
}

struct ErrorMessage: View {
    var error: Error
    
    var body: some View {
        HStack {
            Image(systemName: determineImage())
                .foregroundStyle(.white, determineColor())
                .font(.headline)
            
            Text(error.message)
                .font(.custom("LuckiestGuy-Regular", size: 15))
                .baselineOffset(-3)
                .foregroundStyle(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .stroke(determineColor(), lineWidth: 6)
                .stroke(.black, lineWidth: 0.2)
                .background(.gray)
                .clipShape(Capsule())
        }
    }
    
    func determineColor() -> Color {
        switch(error.errorType) {
            case .error:
                return .red
            case .success:
                return .green
            case .none:
                return .blue
        }
    }
    
    func determineImage() -> String {
        switch(error.errorType) {
            case .error:
                return "x.circle.fill"
            case .success:
                return "checkmark.circle.fill"
            case .none:
                return "circle.fill"
        }
    }
}

#Preview {
    ErrorMessage(error: Error(message: "This is for something bad", errorType: .error))
}
