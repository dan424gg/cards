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
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("terminated")
    }
}

@main
struct CardsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var showLaunch: Bool = true
        
    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                ZStack {
                    ContentView()
                    
                    ZStack {
                        if showLaunch {
                            LaunchView(showLaunch: $showLaunch)
                                .transition(.blurReplace())
                        }
                    }
                    .zIndex(2.0)
                }
                .modelContainer(for: GameModel.self)
                .environment(GameHelper())
                .environment({ () -> DeviceSpecs in
                    let envObj = DeviceSpecs()
                    envObj.setProperties(geo)
                    envObj.theme = UserDefaults.standard.object(forKey: AppStorageConstants.theme) as? ColorTheme ?? .classic
                    return envObj
                }() )
            }
            .ignoresSafeArea()
        }
    }
}
