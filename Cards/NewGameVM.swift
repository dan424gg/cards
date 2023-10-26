//
//  ViewModel.swift
//  Cards
//
//  Created by Daniel Wells on 10/7/23.
//  Copyright © 2023 orgName. All rights reserved.
//

import Foundation

extension NewGame {
    @MainActor class NewGameVM: ObservableObject {
        @Published private(set) var id = 0 as NSNumber
        
        func doTask() async {
//            do {
//                id =  try await GameInformation().GetGroupId() as NSNumber
//
//            } catch {
//                print(error)
//            }
        }
    }
}
