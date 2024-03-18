//
//  ContentView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

struct ContentView:View{
    @EnvironmentObject var appStateViewModel:AppStateViewModel
    @StateObject private var firestoreViewModel: FirestoreViewModel
    @StateObject var navigationViewModel: NavigationViewModel
    init(){
        self._firestoreViewModel = StateObject(wrappedValue: FirestoreViewModel())
        self._navigationViewModel = StateObject(wrappedValue: NavigationViewModel())
        UINavigationBar.changeAppearance(clear: true)
    }
    
    var body:some View{
        ZStack{
            if appStateViewModel.launchState[LaunchState.STARTED.rawValue] {
                HomeView()
                .toast(isShowing: $appStateViewModel.showToast)
                .environmentObject(firestoreViewModel)
                .environmentObject(navigationViewModel)
            }
        }
        .task{
            firestoreViewModel.updateLoadingStateWith(state: .TENT_ASSETS, value: true)
            firestoreViewModel.loadTentAssets()
            appStateViewModel.start()
        }
    }
}
