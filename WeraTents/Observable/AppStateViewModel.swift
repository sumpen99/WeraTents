//
//  LaunchScreenViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

enum LaunchState:Int,CaseIterable{
    case STARTED
    case FINNISHED
}

class AppStateViewModel:ObservableObject{
    @MainActor @Published var launchState:[Bool] = Array(repeating: false, count: LaunchState.allCases.count)
    @Published var showToast:Bool = false
    
    @MainActor func start(){
        launchState[LaunchState.STARTED.rawValue] = true
    }
    
    @MainActor func end(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.launchState[LaunchState.FINNISHED.rawValue] = true
        }
    }
    
    @MainActor
    func activateToast(_ state:ToastState,_ message:String,onDone:(() -> Void)? = nil){
        ToastConfiguration.config(state: state, message: message)
        DispatchQueue.main.async {
            withAnimation{
                self.showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + ToastConfiguration.duration){
                    self.showToast = false
                    onDone?()
                }
            }
        }
        
    }
}
