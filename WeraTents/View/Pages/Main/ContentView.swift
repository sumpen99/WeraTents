//
//  ContentView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

struct ContentView: View {
    init(){
        UINavigationBar.changeAppearance()
    }
  
    var body:some View{
        MainView()
    }
    /*
    var body: some View {
        switch firebaseAuth.loggedInAs{
            case .NOT_LOGGED_IN:
                WelcomeView()
            case .ANONYMOUS_USER:
                MainAnonymousView()
            case .REGISTERED_USER:
                MainView()
            case .ADMIN_USER:
                MainView()
        }
    }*/
}
