//
//  ARView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import Combine

struct ModelARView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    var content:some View{
        ZStack(alignment: .bottom) {
            ARViewContainer()
            HStack{
                Button(action: {
                    ActionManager.shared.actionStream.send(.place3DModel)
                }, label: {
                    Text("Put Tent")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                })
                
                Button(action: {
                    ActionManager.shared.actionStream.send(.remove3DModel)
                }, label: {
                    Text("Delete Tent")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                })
            }
            .padding(.bottom, 50)
            
        }
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            content
                .modifier(NavigationViewModifier(color:.lightGreen))
            
        }
    }
}
