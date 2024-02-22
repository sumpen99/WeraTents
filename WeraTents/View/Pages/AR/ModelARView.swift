//
//  ARView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

struct ModelARView: View {
    @StateObject private var arViewCoordinator: ARViewCoordinator
    
    init() {
        self._arViewCoordinator = StateObject(wrappedValue: ARViewCoordinator())
     }
    
    var arContent:some View{
      ARViewContainer(arViewCoordinator: arViewCoordinator)
    }
    
    var simulatorContent:some View{
        Text("Simulator View").hCenter().vCenter()
    }
        
    var body: some View{
        ZStack{
        Color.lightGreen
#if targetEnvironment(simulator)
        simulatorContent
#else
        arContent
#endif
       }
        .toolbar(.hidden)
        .ignoresSafeArea(.all)
        .customBackButton(imgLabel: "xmark",color: .white,action: releaseMemory)
        .safeAreaInset(edge: .bottom){
            bottomButtons
        }

    }
}

//MARK: -- FUNCTIONS
extension ModelARView{
    func releaseMemory(){
        arViewCoordinator.kill()
        //ActionManager.shared.actionStream.send(.killSession)
     }
    
    func removeModel(){
        arViewCoordinator.action(.remove3DModel)
        //ActionManager.shared?.actionStream.send(.remove3DModel)
    }
    
    func placeModel(){
        arViewCoordinator.action(.place3DModel)
        //ActionManager.shared?.actionStream.send(.place3DModel)
    }
}

//MARK: -- BUTTONS
extension ModelARView{
    
    var navigateBackButton:some View{
        BackButton(color:.black,action:releaseMemory)
        .hLeading()
    }
    
    var placeModelButton:some View{
        Button(action: placeModel, label: {
            roundedImage("plus",font:.largeTitle,scale:.large,radius: 70.0)
        })
    }
    
    var removeModelButton:some View{
        Button(action: removeModel, label: {
            roundedImage("minus",font:.title,scale:.medium,radius: 40.0)
        })
    }
    
    var infoModelButton:some View{
        Button(action: removeModel, label: {
            roundedImage("info",font:.title,scale:.medium,radius: 40.0)
        })
    }
    
    var bottomButtons:some View{
        HStack{
            removeModelButton
            placeModelButton.hCenter()
            infoModelButton
        }
        .padding([.leading,.trailing])
    }
}
