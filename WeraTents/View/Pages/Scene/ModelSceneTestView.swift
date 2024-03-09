//
//  ModelSceneViewTest.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-09.
//

import SwiftUI
import SceneKit
struct ModelSceneTestView: View {
            
    var body: some View{
        SceneViewTestContainer()
    }
}

struct SceneViewTestContainer: UIViewRepresentable {
    typealias UIViewType = SCNView
    typealias Context = UIViewRepresentableContext<SceneViewTestContainer>
    
    func makeUIView(context: Context) -> UIViewType {
        return SCNView(frame:.zero)
    }
  
    func updateUIView(_ scnView: UIViewType, context: Context){
        if let url = Bundle.main.url(forResource: "Assets/tent-2-man-tent", withExtension: "usdz"){
            //let scene = try? SCNScene(url: url, options: [.checkConsistency: true])
            
            let tentNode = SCNReferenceNode(url: url)
            tentNode?.load()
            
            //scnView.scene = scene
        }
    }
}

