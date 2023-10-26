//
//  CardsApp.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct CardsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseHelper = FirebaseHelper()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseHelper)
            
        }
    }
}
