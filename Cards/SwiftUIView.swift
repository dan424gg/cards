//
//  SwiftUIView.swift
//  Cards
//
//  Created by Daniel Wells on 1/18/24.
//

import SwiftUI

struct SwiftUIView: View {
    @State var temp = ["1", "2", "3"]
    
    var body: some View {
        TimedTextContainer(textArray: $temp, visibilityFor: 2.0, delay: 1.0)
    }
}

#Preview {
    SwiftUIView()
}
