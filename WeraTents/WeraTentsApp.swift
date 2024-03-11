//
//  WeraTentsApp.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

@main
struct WeraTentsApp: App {
    @StateObject var appStateViewModel = AppStateViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) private var phase
    let persistenceController = PersistenceController.shared
   
    var body: some Scene {
        StyledWindowGroup {
            ZStack{
                ContentView()
                if !appStateViewModel.launchState[LaunchState.FINNISHED.rawValue] {
                    LaunchScreen()
                }
            }
            .environmentObject(appStateViewModel)
            .preferredWindowColor(Color.background)
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

/*
//MARK: - TBB Global TLS count is not == 1, instead it is: 2 När vi laddar in usdz filen
@main
struct WeraTentsApp: App {
    var body: some Scene {
        WindowGroup{
             ModelSceneTestView()
        }
    }
}
*/
