//
//  ARViewController.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//
import SwiftUI
import RealityKit

struct ARViewRepresentable: UIViewRepresentable {
    typealias UIViewType = ARView
    typealias Context = UIViewRepresentableContext<ARViewRepresentable>
    
    func makeUIView(context: Context) -> UIViewType {
        return ARTentView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    static func dismantleUIView(_ context: Context, coordinator: Coordinator) {
        //coordinator.pauseSession()
        debugLog(object: "dismantleARView: \(context)")
    }
}



