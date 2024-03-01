//
//  ModelSceneView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-01.
//

import SwiftUI
import SceneKit

struct ModelSceneView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView(frame:.zero)
        
        if let url = Bundle.main.url(forResource: "Assets/tent-2-man-tent", withExtension: "usdz") {
            let scene = try! SCNScene(url: url, options: nil)
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
            scene.rootNode.addChildNode(lightNode)
            scene.rootNode.scale = SCNVector3(0.5, 0.5, 0.5)
            SCNNode.createBorderOnNode(scene.rootNode)
            scnView.scene = scene
            scnView.autoenablesDefaultLighting = true
            scnView.allowsCameraControl = true
            //scnView.backgroundColor = UIColor.black
        }
        else{
            debugLog(object: "nepp")
        }
        
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context){
    }
    
    
}
