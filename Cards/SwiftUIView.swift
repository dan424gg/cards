//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @State var scale: Double = 0.0
    
    var body: some View {
        VStack{
            temp1(scale: $scale)
            temp1(scale: .constant(15))
            Button("hit me") {
                scale += 1.0
            }
        }
    }
}

struct temp1: View {
    @Binding var scale: Double
    
    var body: some View {
        Text("\(scale)")
    }
}

#Preview {
    SwiftUIView()
}
