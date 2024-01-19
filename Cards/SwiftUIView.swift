//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
//    @State var temp: [String] = []
    @State var index: Int = 0
    
    var body: some View {
        Text("\(index)")
            .onAppear(perform: {
                var temp = 0
                var i = 0
                for i in 0...10 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (2.0 * Double(i))) {
                        print("from dispatch: \(i + temp)")
                    }
                    temp += 1
                    print("from for loop \(i + temp)")
                }
            })
        Button("increment") {
            index += 1
        }
    }
}

#Preview {
    SwiftUIView()
}
