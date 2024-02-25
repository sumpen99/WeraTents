//
//  LaunchScreenViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import Foundation

enum LaunchState{
    case START
    case CONTINUE
    case FINISHED
}

class LaunchScreenViewModel:ObservableObject{
   @MainActor @Published var state:LaunchState = .START
    
    @MainActor func dismiss(){
        Task{
            state = .CONTINUE
            try? await Task.sleep(for: Duration.seconds(1))
            self.state = .FINISHED
        }
    }
}
