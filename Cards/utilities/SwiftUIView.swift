import SwiftUI

struct SwiftUIView: View {
    @State var cards: [Int] = [0,1,2,3]
    
    var body: some View {
        VStack {
            Text("\(foo(cards))")
            Button("do something") {
                cards = [4]
            }
        }
    }
    
    func foo(_ cards: [Int]) -> Int {
        var temp = cards
        return temp.last!
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
