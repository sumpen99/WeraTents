//
//  WeraTentsApp.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

@main
struct WeraTentsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var phase
    var body: some Scene {
        StyledWindowGroup {
            ContentView()
            .preferredWindowColor(Color.white)
            .onChange(of: phase,initial: true) { newPhase,initial in
                switch newPhase {
                case .active:
                    debugLog(object:phase)
                case .inactive:
                    debugLog(object:phase)
               case .background:
                    debugLog(object:phase)
                @unknown default:
                    debugLog(object:"Unknown Future Options")
              }
            }
        }
    }
}
