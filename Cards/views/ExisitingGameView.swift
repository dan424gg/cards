//
//  ExistingGameView.swift
//  Cards
//
//  Created by Daniel Wells on 3/10/24.
//

import SwiftUI

struct ExistingGameView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var notValid: Bool = true
    @State var groupId: String = ""
    @State var fullName: String = ""
    @State var size: CGSize = .zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
                .fill(.white)
                .fill(Color("OffWhite").opacity(0.2))
                .frame(width: 300, height: 300)
            
            VStack {
                Text("Join Game")
                    .font(.title2)
                CustomTextField(textFieldHint: "Group ID", value: $groupId)
                CustomTextField(textFieldHint: "Name", value: $fullName)
                
                Button("Submit", systemImage: notValid ? "x.circle" : "checkmark.circle", action: {
                    Task {
                        await firebaseHelper.joinGameCollection(fullName: fullName, id: groupId)
                    }
                })
                .labelStyle(.iconOnly)
                .symbolRenderingMode(.palette)
                .foregroundStyle(notValid ? .gray.opacity(0.5) : .green)
                .disabled(notValid)
                .font(.system(size: 35))
            }
            .onChange(of: [fullName, groupId], {
                if fullName.isEmpty || (groupId.isEmpty) {
                    withAnimation {
                        notValid = true
                    }
                } else {
                    if !groupId.isEmpty {
                        Task {
                            if await firebaseHelper.checkValidId(id: groupId) {
                                withAnimation {
                                    notValid = false
                                }
                            } else {
                                withAnimation {
                                    notValid = true
                                }
                            }
                        }
                    } else {
                        withAnimation {
                            notValid = false
                        }
                    }
                }
            })
        }
        .onTapGesture {
            endTextEditing()
        }
    }
}

#Preview {
    return GeometryReader { geo in
        ExistingGameView()
            .environmentObject({ () -> DeviceSpecs in
                let envObj = DeviceSpecs()
                envObj.setProperties(geo)
                return envObj
            }() )
            .environmentObject(FirebaseHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .ignoresSafeArea()
}
