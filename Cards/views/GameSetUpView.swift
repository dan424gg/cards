//
//  GameSetUpView.swift
//  Cards
//
//  Created by Daniel Wells on 2/25/24.
//

import SwiftUI

struct GameSetUpView: View {
    @EnvironmentObject var firebaseHelper: FirebaseHelper
    @EnvironmentObject var specs: DeviceSpecs
    @StateObject var sheetCoordinator = SheetCoordinator<SheetType>()
    @FocusState private var isFocused: Bool
    @State private var notValid: Bool = true
    @State var groupId: String = ""
    @State var fullName: String = ""
    @State var gameName: String = ""
    @State var size: CGSize = .zero
    
    var setUpType: GameSetUpType
    
    var body: some View {
        VStack {
            switch setUpType {
                case .newGame:
                    Text("New Game")
                        .font(.title2)
                    CustomTextField(textFieldHint: "Name", value: $fullName)
                case .existingGame:
                    Text("Join Game")
                        .font(.title2)
                    CustomTextField(textFieldHint: "Group ID", value: $groupId)
                    CustomTextField(textFieldHint: "Name", value: $fullName)
            }
            
            Button("Submit", systemImage: notValid ? "x.circle" : "checkmark.circle", action: {
                sheetCoordinator.showSheet(.loadingScreen)
                Task {
                    switch setUpType {
                        case .newGame:
                            await firebaseHelper.startGameCollection(fullName: fullName)
                        case .existingGame:
                            await firebaseHelper.joinGameCollection(fullName: fullName, id: groupId)
                    }
                }
            })
            .labelStyle(.iconOnly)
            .symbolRenderingMode(.palette)
            .foregroundStyle(notValid ? .gray.opacity(0.5) : .green)
            .disabled(notValid)
            .font(.system(size: 35))
        }
        .onChange(of: [fullName, groupId], {
            if fullName.isEmpty || (groupId.isEmpty && setUpType == .existingGame) {
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
        .onAppear {
            size = CGSize(width: specs.maxX * 0.66, height: specs.maxY * 0.25)
        }
        .frame(width: specs.maxX * 0.66, height: specs.maxY * 0.25)
        .position(x: specs.maxX / 2, y: size.height / 2)
        .onTapGesture {
            endTextEditing()
        }
    }
}

enum GameSetUpType {
    case newGame
    case existingGame
}

#Preview {
    return GeometryReader { geo in
        GameSetUpView(setUpType: .existingGame)
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
