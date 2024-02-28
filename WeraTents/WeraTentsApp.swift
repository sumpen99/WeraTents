//
//  WeraTentsApp.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

@main
struct WeraTentsApp: App {
    @StateObject var launchScreenViewModel = LaunchScreenViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var phase
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        StyledWindowGroup {
            ZStack{
                ContentView()
                if launchScreenViewModel.state != .FINISHED {
                    LaunchScreen()
                }
            }
            .environmentObject(launchScreenViewModel)
            .preferredWindowColor(Color.clear)
            .onChange(of: phase,initial: true) { newPhase,initial in
                try? persistenceController.saveContext()
                /*switch newPhase {
                case .active:
                    debugLog(object:phase)
                case .inactive:
                    debugLog(object:phase)
               case .background:
                    debugLog(object:phase)
                @unknown default:
                    debugLog(object:"Unknown Future Options")
              }*/
            }
        }
    }
}
