//
//  NavigationViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

enum ModelRoute: Identifiable{
    case ROUTE_AR
    case ROUTE_CAPTURED_IMAGES
    
    var id: Int {
        hashValue
    }
    
}

class NavigationViewModel: ObservableObject{
    @Published var pathTo:NavigationPath = NavigationPath()
    var notEmptyPath:Bool{ pathTo.count > 0 }
    
    func switchPathToRoute<T:Hashable>(_ route:T){
        self.clearPath()
        self.pathTo.append(route)
    }
    
    func appendToPathWith<T:Hashable>(_ t:T){
        self.pathTo.append(t)
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
