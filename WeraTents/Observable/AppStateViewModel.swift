//
//  LaunchScreenViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

enum LaunchState{
    case START
    case CONTINUE
    case FINISHED
}

class AppStateViewModel:ObservableObject{
   @MainActor @Published var launchState:LaunchState = .START
    @Published var showToast:Bool = false
    
    @MainActor func dismiss(){
        Task{
            launchState = .CONTINUE
            try? await Task.sleep(for: Duration.seconds(1.4))
            self.launchState = .FINISHED
        }
    }
    
    func activateToast(_ state:ToastState,_ message:String,onDone:(() -> Void)? = nil){
        ToastConfiguration.config(state: state, message: message)
        withAnimation{
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + ToastConfiguration.duration){
                self.showToast = false
                onDone?()
            }
        }
    }
}
