//
//  ExistingGameView.swift
//  Cards
//
//  Created by Daniel Wells on 3/10/24.
//

import SwiftUI

struct ExistingGameView: View {
    @Binding var introView: IntroViewType
    @EnvironmentObject var gameHelper: GameHelper
    @EnvironmentObject var specs: DeviceSpecs
    @State private var notValid: Bool = true
    @State var groupId: String = ""
    @State var fullName: String = ""
    @State var size: CGSize = .zero
    
    @State var showErrorMessage: Bool = false
    @State var alert: Alert?
    @State var timer: Timer?
    
    func validateGroupId(groupId: String) async -> Bool  {
        if await gameHelper.checkValidId(id: groupId) {
            if await gameHelper.checkGameInProgress(id: groupId) {
                withAnimation {
                    alert = Alert(title: "Game In Progress", message: "Game ID is already in progress!")
                }
                
                return false
            } else if await gameHelper.checkNumberOfPlayersInGame(id: groupId) >= 4 {
                withAnimation {
                    alert = Alert(title: "Too Many Players", message: "That game is at capacity already!")
                }
                
                return false
            }
            
            
        } else {
            withAnimation {
                print("Game ID is not valid! \(groupId)")
                alert = Alert(title: "Game Id Error", message: "Game ID is not valid!")
            }
            
            return false
        }
        
        return true
    }
    
    func validateName(name: String) -> Bool {
        if name.isEmpty {
            withAnimation {
                alert = Alert(title: "Error", message: "Your name can't be blank!")
            }
            
            return false
        } else if name == "" {
            withAnimation {
                alert = Alert(title: "Error", message: "Your name can't be blank!")
            }
            
            return false
        } else if name.count == 0 {
            withAnimation {
                alert = Alert(title: "Error", message: "Your name can't be blank!")
            }
            
            return false
        }
        
        return true
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                CText("Join Game", size: 40)
                    .foregroundStyle(specs.theme.colorWay.white)
                    .frame(height: 40)
                
                VStack(spacing: 5) {
                    CustomTextField(textFieldHint: "Game ID", asyncValidationFunciton: validateGroupId, value: $groupId)
                        .keyboardType(.numberPad)
                    
                    CustomTextField(textFieldHint: "Name", validationFunciton: validateName, value: $fullName)
                }
                
                CustomButton(name: "Submit", submitFunction: {
                    endTextEditing()
                    
                    Task {
                        if await validateGroupId(groupId: groupId) && validateName(name: fullName) {
                            gameHelper.reinitialize()
                            gameHelper.logAnalytics(.name_length, ["name_length": fullName.count])
                            await gameHelper.joinGameCollection(fullName: fullName, id: groupId)
                            withAnimation(.smooth(duration: 0.3)) {
                                introView = .loadingScreen
                            }
                        }
                    }
                })
            }
            .padding()
            .frame(width: specs.maxX * 0.8)
            .background {
                RoundedRectangle(cornerRadius: 20.0)
                    .fill(specs.theme.colorWay.primary)
                    .shadow(radius: 10)
            }
            .overlay(alignment: .topTrailing) {
                ImageButton(image: Image(systemName: "x.circle.fill"), submitFunction: {
                    withAnimation(.snappy.speed(1.0)) {
                        introView = .nothing
                        endTextEditing()
                    }
                })
                .offset(x: 20.0, y: -20.0)
                .font(.system(size: 45, weight: .heavy))
                .foregroundStyle(specs.theme.colorWay.primary, specs.theme.colorWay.secondary)
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .alertWindow($alert)
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
            .environmentObject(GameHelper())
            .position(x: geo.frame(in: .global).midX, y: geo.frame(in: .global).midY)
    }
    .background(DeviceSpecs().theme.colorWay.background)
    .ignoresSafeArea()
}
