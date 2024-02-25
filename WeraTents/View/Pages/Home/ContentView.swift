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
    init(){
        self._firestoreViewModel = StateObject(wrappedValue: FirestoreViewModel())
    }
    var body:some View{
        ZStack{
            if launchScreenViewModel.state == .FINISHED {
                HomeView()
                .environmentObject(firestoreViewModel)
            }
        }
        .task{
            firestoreViewModel.loadImageAssets()
            try? await Task.sleep(for: Duration.seconds(1))
            self.launchScreenViewModel.dismiss()
        }
    }
}
