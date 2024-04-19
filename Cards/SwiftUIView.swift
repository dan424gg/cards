import SwiftUI

struct SwiftUIView: View {
    @State var counter: Int = 0
    
    var body: some View {
        VStack {
            Text(determineText())
            Button("incr") {
                counter += 1
            }
        }
    }
    
    func determineText() -> String {
        if counter % 2 == 0 {
            return "\(counter)"
        } else {
            return "odd!"
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
