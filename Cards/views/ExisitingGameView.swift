//
//  ExistingGameView.swift
//  Cards
//
//  Created by Daniel Wells on 3/10/24.
//

import SwiftUI

struct ExistingGameView: View {
    @Binding var introView: IntroViewType
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var notValid: Bool = true
    @State var groupId: String = ""
    @State var fullName: String = ""
    @State var size: CGSize = .zero
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
//                .fill(.white)
                .fill(Color.theme.primary)
                .frame(width: 300, height: 300)
            
            VStack {
                Text("Join Game")
                    .font(.custom("LuckiestGuy-Regular", size: 40))
                    .offset(y: 5)
                    .foregroundStyle(Color.theme.white)
                    .getSize(onChange: {
                        print($0)
                    })
                
                CustomTextField(textFieldHint: "Group ID", value: $groupId)
                CustomTextField(textFieldHint: "Name", value: $fullName)
                
                Button {
                    endTextEditing()
                    
                    Task {
                        await firebaseHelper.joinGameCollection(fullName: fullName, id: groupId)
                        withAnimation(.smooth(duration: 0.3)) {
                            introView = .loadingScreen
                        }
                    }
                } label: {
                    Text("Submit")
                        .padding()
                        .foregroundStyle(Color.white)
                        .font(.custom("LuckiestGuy-Regular", size: 25))
                        .offset(y: 2.2)
                        .frame(width: 150)
                }
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
        ExistingGameView(introView: .constant(.nothing))
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
