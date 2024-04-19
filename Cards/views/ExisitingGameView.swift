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
    
    @State var showErrorMessage: Bool = false
    @State var error: Error? = nil
    @State var timer: Timer?
    
    func validateGroupId(groupId: String) {
        Task {
            if await firebaseHelper.checkValidId(id: groupId) {
                if error != nil {
                    withAnimation {
                        error = Error(message: "Valid!", errorType: .success)
                    }
                }
            } else {
                withAnimation {
                    error = Error(message: "Group Id is not valid!", errorType: .error)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            if error != nil {
                ErrorMessage(error: error!)
                    .geometryGroup()
                    .onChange(of: error, initial: true, {
                        timer?.invalidate()
                        timer = nil
                        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false, block: { _ in
                            withAnimation {
                                error = nil
                            }
                        })
                    })
                    .frame(height: 150)
                    .offset(y: -170)
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
            }
            
            VStack(spacing: 20) {
                Text("Join Game")
                    .font(.custom("LuckiestGuy-Regular", size: 40))
                    .baselineOffset(-5)
                    .foregroundStyle(Color.theme.white)
                    .frame(height: 40)
                
                VStack(spacing: 5) {
                    CustomTextField(textFieldHint: "Group ID", validationFunciton: validateGroupId, value: $groupId)
                        .keyboardType(.numberPad)
                    CustomTextField(textFieldHint: "Name", value: $fullName)
                }
                
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .font(.custom("LuckiestGuy-Regular", size: 24))
                        .baselineOffset(-5)
                        .foregroundStyle(Color.theme.primary)
                        .background(Color.theme.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(Color.theme.primary)
                    .frame(width: 300)
            }
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
    .background(Color.theme.background)
    .ignoresSafeArea()
}
