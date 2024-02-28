//
//  ContentView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

struct ContentView:View{
    @EnvironmentObject var launchScreenViewModel:LaunchScreenViewModel
    @StateObject private var firestoreViewModel: FirestoreViewModel
    @StateObject var navigationViewModel: NavigationViewModel
    init(){
        self._firestoreViewModel = StateObject(wrappedValue: FirestoreViewModel())
        self._navigationViewModel = StateObject(wrappedValue: NavigationViewModel())
    }
    var body:some View{
        ZStack{
            if launchScreenViewModel.state == .FINISHED {
                HomeView()
                .environmentObject(firestoreViewModel)
                .environmentObject(navigationViewModel)
            }
        }
        .task{
            firestoreViewModel.loadImageAssets()
            //try? await Task.sleep(for: Duration.seconds(1.5))
            self.launchScreenViewModel.dismiss()
        }
    }
}
