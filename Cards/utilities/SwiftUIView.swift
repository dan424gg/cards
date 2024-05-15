import SwiftUI

struct SwiftUIView: View {
    @State var bool: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Button("heavy") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                })
            }
            
            Button("heavy 1") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 1)
            }
            
            Button("heavy 2") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 2)
            }
            
            Button("heavy 5") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 5)
            }
            
            Button("heavy 10") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 10)
            }
            
            Button("rigid") {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }
            
            Button("rigid 5") {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 5)
            }
        }
        .buttonStyle(.bordered)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
