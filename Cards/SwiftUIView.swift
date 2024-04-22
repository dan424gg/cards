import SwiftUI

struct SwiftUIView: View {
    @State var display: Bool = true
    @State var text: [String] = ["1 for last card!"]
    
    var body: some View {
        VStack {
            TimedTextContainer(display: $display, textArray: .constant(text), visibilityFor: 2.0)
                .getSize(onChange: { print($0) })
//            Button("do something") {
//                text = ["this again", "another thing"]
//                display = true
//            }
        }
    }
}

struct DetermineText: View {
    @Binding var counter: Int
    
    var body: some View {
        VStack {
            Text("\(counter)")
            Button("incr") {
                withAnimation {
                    counter += 1
                }
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
