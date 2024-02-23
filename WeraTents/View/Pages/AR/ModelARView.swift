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
    
    @ViewBuilder
     var arContent:some View{
         if !arViewCoordinator.load{
             ARViewContainer(arViewCoordinator: arViewCoordinator)
         }
         else{
             Text("Loading")
         }
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
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                arViewCoordinator.load = false
            })
            
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
     }
    
    func removeModel(){
        arViewCoordinator.action(.remove3DModel)
    }
    
    func placeModel(){
        arViewCoordinator.action(.place3DModel)
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
