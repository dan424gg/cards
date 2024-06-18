import SwiftUI

struct SwiftUIView: View {
    @State var counter: Int = 0
    @State var lastPressTime: Date?
    
    var body: some View {
        VStack {
            Text("\(counter)")
            CustomButton(name: "incr", submitFunction: {
                counter += 1
            })
            
            Button("incr") {
                let currentTime = Date()
                
                // Check if the button was pressed recently
                if let lastPress = lastPressTime, currentTime.timeIntervalSince(lastPress) < 2 {
                    print("Button press ignored, too soon after last press \(lastPress).")
                    return
                }

                // Update the last press time
                lastPressTime = currentTime
                
                counter += 1
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
            .environmentObject(DeviceSpecs())
    }
}
