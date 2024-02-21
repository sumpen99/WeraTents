//
//  HomeView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

struct HomeView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var content:some View{
        Text("Home")
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            content
            .modifier(NavigationViewModifier(color:.lightGreen))
            
        }
    }
}
