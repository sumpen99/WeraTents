//
//  NavigationViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

enum MainTabItem{
    case HOME
    case AR
    case PROFILE
}

class NavigationViewModel: ObservableObject{
    @Published var selectedTab:MainTabItem = .HOME
    @Published var pathTo:NavigationPath = NavigationPath()
    
    var notEmptyPath:Bool{ pathTo.count > 0 }
    
    func navTo(_ tab:MainTabItem){
        if(isActive(tab)){NavigationUtil.popToRootView()}
        else{nav(tab)}
    }
    
    private func nav(_ tab:MainTabItem){
        DispatchQueue.main.async {
            self.clearPath()
            self.selectedTab = tab
        }
    }
    
    func isActive(_ tab:MainTabItem) -> Bool{
        return selectedTab == tab
    }
    
    func switchPathToRoute<T:Hashable>(_ route:T){
        clearPath()
        pathTo.append(route)
    }
    
    func appendToPathWith<T:Hashable>(_ t:T){
        pathTo.append(t)
    }
    
    func clearPath(){
        if notEmptyPath{ pathTo.removeLast(pathTo.count) }
    }
    
    func popPath(){
        if notEmptyPath{ pathTo.removeLast() }
    }
    
    func reset(){
        if notEmptyPath{
            pathTo.removeLast(pathTo.count)
            NavigationUtil.popToRootView()
            
        }
    }
        
}
