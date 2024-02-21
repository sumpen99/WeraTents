//
//  HomeView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

struct MainView:View {
    @StateObject var navigationViewModel = NavigationViewModel()
    var tabMenu: some View {
        TabView(selection:$navigationViewModel.selectedTab) {
            Group{
                HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(MainTabItem.HOME)
                ModelARView()
                .tabItem {
                    Label("Camera", systemImage: "camera")
                }
                .tag(MainTabItem.AR)
                ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(MainTabItem.PROFILE)
            }
            .toolbarBackground(.darkGreen, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
       }
        .onChange(of: navigationViewModel.selectedTab,initial: true){ route,initial in
            navigationViewModel.reset()
        }
    }
    
    var body: some View {
        tabMenu
        .environmentObject(navigationViewModel)
        .ignoresSafeArea(.keyboard)
    }
}
