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
    @State var showLaunch: Bool = true
    @StateObject private var firebaseHelper = FirebaseHelper()
    @StateObject private var deviceSpecs = DeviceSpecs()
        
    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                ZStack {
                    ContentView()
                        .environmentObject(firebaseHelper)
                        .environmentObject({ () -> DeviceSpecs in
                            let envObj = DeviceSpecs()
                            envObj.setProperties(geo)
                            return envObj
                        }() )
                    
                    ZStack {
                        if showLaunch {
                            LaunchView(showLaunch: $showLaunch)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .zIndex(2.0)
                }
            }
            .ignoresSafeArea()
        }
    }
}
