import SwiftUI

struct SwiftUIView: View {
    @State var counter: Int = 0
    @State var isProcessing: Bool = false
    
    var body: some View {
        VStack {
            Text("\(counter)")
            CustomButton(name: "incr", submitFunction: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    counter += 1
                }
            })
            
//            Button("incr") {
//                guard !isProcessing else { return } // Check if already processing
//                isProcessing = true // Set processing flag
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    counter += 1
//                }
//                
//                isProcessing = false // Release lock
//            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
            .environment(DeviceSpecs())
    }
}
