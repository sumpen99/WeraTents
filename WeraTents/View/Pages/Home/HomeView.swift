//
//  HomeView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

enum ModelRoute: Identifiable{
    case ROUTE_AR
    
    var id: Int {
        hashValue
    }
    
}

struct HomeView:View {
    @StateObject var navigationViewModel = NavigationViewModel()
    var content:some View{
        ZStack{
            Text("Home").hCenter().vCenter()
        }
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .bottom){
            navModelARButton
        }
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            content
            .modifier(NavigationViewModifier(color:.lightGreen))
            .navigationDestination(for: ModelRoute.self){  route in
                switch route{
                case .ROUTE_AR: ModelARView()
                }
            }
       }
    }
}

//MARK: -- NAVIGATION
extension HomeView{
    var navModelARButton:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_AR)}, label: {
            roundedImage("camera",font:.largeTitle,scale:.large,radius: 80.0,foreground: Color.white,background: Color.darkGreen)
        })
    }
}
