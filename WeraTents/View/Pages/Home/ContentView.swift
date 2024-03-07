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
    }
    var body:some View{
        ZStack{
            if appStateViewModel.launchState == .FINISHED {
                HomeView()
                .toast(isShowing: $appStateViewModel.showToast)
                .environmentObject(firestoreViewModel)
                .environmentObject(navigationViewModel)
            }
        }
         .task{
             if FETCH_LOCALLY{ firestoreViewModel.loadTentAssetsFromLocal() }
             else{ firestoreViewModel.loadTentAssetsFromServer() }
             self.appStateViewModel.dismiss()
        }
    }
}
