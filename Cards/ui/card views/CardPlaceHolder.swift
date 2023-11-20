//
//  CardPlaceHolder.swift
//  Cards
//
//  Created by Daniel Wells on 11/1/23.
//

import SwiftUI

struct CardPlaceHolder: View {
    var body: some View {
        ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, style: StrokeStyle(lineWidth: 1, dash: [4]))
                    )
                    .overlay(
                        Text("Place a card here!")
                            .font(.system(size: 7))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.black.opacity(0.9))
                    )
            }
    }
}

#Preview {
    CardPlaceHolder()
}
