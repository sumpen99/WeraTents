//
//  ProfileView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

struct ProfileView:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var content:some View{
        Text("Profile")
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            content
            .modifier(NavigationViewModifier(color:.lightGreen))
            
        }
    }
}
