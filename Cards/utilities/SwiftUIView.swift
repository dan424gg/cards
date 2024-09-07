

import Combine
import Foundation
import SwiftUI
import SwiftData
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

enum buttonType {
    case add, remove, none
}

struct SwiftUIView: View {
    @State var nums: [Int] = [0]
    @State var butType: buttonType = .none
    
    var body: some View {
        VStack {
            Text("\(nums)")
            
            CustomButton(name: "add", submitFunction: {
                butType = .add
            })
            
            CustomButton(name: "remove", submitFunction: {
                butType = .remove
            })
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
            .environment(DeviceSpecs())
    }
}
