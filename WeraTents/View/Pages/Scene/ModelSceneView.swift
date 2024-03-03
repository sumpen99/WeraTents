//
//  ModelSceneView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-01.
//

import SwiftUI

struct ModelSceneView: View {
    @StateObject private var sceneViewCoordinator: SceneViewCoordinator
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    let selectedTent:TentItem?
    init(selectedTent:TentItem?) {
        self._sceneViewCoordinator = StateObject(wrappedValue: SceneViewCoordinator())
        self.selectedTent = selectedTent
    }
            
    var body: some View{
        mainContent
        .ignoresSafeArea()
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            topButtons
        }
     
    }
}


//MARK: - MAIN CONTENT
extension ModelSceneView{
    var mainContent:some View{
        ZStack{
        Color.black
            SceneViewContainer(sceneViewCoordinator: sceneViewCoordinator)
       }
    }
    
}

//MARK: - TOPBAR
extension ModelSceneView{
   
    var selectedTentLabel:some View{
        Text(selectedTent?.title ?? "No Tent")
        .foregroundStyle(Color.white)
        .font(.headline)
        .bold()
     }
    
    var topButtons:some View{
        HStack{
            BackButtonAction(action: navigateBack)
            selectedTentLabel.hCenter()
        }
        .padding()
    }
}

//MARK: - FUNCTIONS
extension ModelSceneView{
  
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
}
