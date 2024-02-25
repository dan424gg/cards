//
//  CardsApp.swift
//  Cards
//
//  Created by Daniel Wells on 10/11/23.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        #if DEBUG
        print("Is UI Test Running: \(UITestingHelper.isUITesting)")
        #endif
        
        return true
    }
}

@main
struct CardsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseHelper = FirebaseHelper()
    @StateObject private var deviceSpecs = DeviceSpecs()
        
    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                ContentView()
                    .environmentObject(firebaseHelper)
                    .environmentObject({ () -> DeviceSpecs in
                        let envObj = DeviceSpecs()
                        envObj.setProperties(geo)
                        return envObj
                    }() )
            }
            .ignoresSafeArea()
        }
    }
}
