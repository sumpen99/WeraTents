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
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    
    var content:some View{
        Text("Home")
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
            .toolbar {
                ToolbarItem(placement: .principal){
                    navModelARButton
                }
             }
            
        }
    }
}

//MARK: -- NAVIGATION
extension HomeView{
    var navModelARButton:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_AR)}, label: {
            ZStack{
                Image(systemName: "arrow.triangle.2.circlepath").font(.title).foregroundStyle(Color(uiColor: .lightGreen))
                Image(systemName: "camera.metering.multispot").imageScale(.small).foregroundStyle(Color(uiColor: .lightGreen))
            }
        })
        .toolbarFontAndPadding()
    }
}
