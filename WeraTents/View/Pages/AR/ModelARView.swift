//
//  ARView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

struct ModelARView: View {
    var arContent:some View{
      ZStack(alignment: .bottom) {
            ARViewRepresentable()
            bottomButtons
      }
      .customBackButton(action: releaseMemory)
    }
        
    var body: some View{
        ZStack{
#if targetEnvironment(simulator)
        EmptyView()
#else
        arContent
#endif
       }

    }
}

//MARK: -- FUNCTIONS
extension ModelARView{
    func releaseMemory(){
        ActionManager.shared.actionStream.send(.killSession)
     }
    
    func removeModel(){
        ActionManager.shared.actionStream.send(.remove3DModel)
    }
    
    func placeModel(){
        ActionManager.shared.actionStream.send(.place3DModel)
    }
}

//MARK: -- BUTTONS
extension ModelARView{
    
    var placeModelButton:some View{
        Button(action: placeModel, label: {
            labelText("Put Tent")
        })
    }
    
    var removeModelButton:some View{
        Button(action: removeModel, label: {
            labelText("Delete Tent")
        })
    }
    
    var bottomButtons:some View{
        HStack{
            placeModelButton
            removeModelButton
        }
        .padding(.bottom, 50)
    }
}

//MARK: -- TEXT
extension ModelARView{
    func labelText(_ text:String) -> some View{
        return Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
    }
}
