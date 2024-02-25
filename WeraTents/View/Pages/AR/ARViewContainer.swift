//
//  ARTentView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import Combine

//MARK: -- INHERIT HASCOLLISION TO ENABLE GESTURES
class MyEntity: Entity, HasAnchoring, HasModel, HasCollision {}

//MARK: -- ACTIONS
enum Actions {
    case PLACE_3D_MODEL
    case REMOVE_3D_MODEL
    case KILL_SESSION
   
}

enum LoadState{
    case INITIAL
    case LOADING
    case DONE
}

//MARK: -- ARVIEWCONTAINER
struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView
    typealias Context = UIViewRepresentableContext<ARViewContainer>
    let arViewCoordinator:ARViewCoordinator
    
    func makeCoordinator() -> ARViewCoordinator {
        return arViewCoordinator
    }
    
    func makeUIView(context: Context) -> UIViewType {
         let arView = ARView(frame: .zero)
        arViewCoordinator.setARView(arView)
        return arView
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
        coordinator.kill()
        uiView.removeFromSuperview()
    }
}

//MARK: -- ARVIEW-COORDINATOR
class ARViewCoordinator: NSObject,ARSessionDelegate,ObservableObject{
    weak var arView: ARView?
    var focusEntity: FocusEntity?
    @Published var state:LoadState = .INITIAL
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        //debugLog(object: "Session did UPDATE FRAME ")
    }
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
        //debugLog(object: "Session did ADD ANCHORS")
    }
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){ 
        //debugLog(object: "Session did UPDATE ANCHORS ")
    }
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]){
        //debugLog(object: "Session did REMOVE ANCHORS ")
    }
    
    func setARView(_ arView: ARView) {
        self.arView = arView
        self.focusEntity = FocusEntity(on: arView, style: .classic())
        self.arView?.runConfiguration()
        self.arView?.session.delegate = self
    }
    
    func kill() {
        self.focusEntity?.destroy()
        self.arView?.kill()
        self.arView = nil
        self.focusEntity = nil
    }
    
    func pause() {
        self.arView?.pause()
    }
    
    func action(_ action:Actions){
        guard let focusEntity = self.focusEntity else { return }
        switch action {
        case .PLACE_3D_MODEL:
            self.arView?.loadEntityAsync(focusEntity.position)
        case .REMOVE_3D_MODEL:
            self.arView?.removeModel()
        case .KILL_SESSION:
            self.arView?.kill()
       }
    }
    
}

//MARK: -- CONFIGURATION
extension ARView{
    func runConfiguration(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            configuration.sceneReconstruction = .meshWithClassification
        }
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

//MARK: -- LOAD MODEL FROM APP
extension ARView{
    func loadEntityAsync(_ position:SIMD3<Float>) {
        let usdzPath = "Assets/tent-2-man-tent.usdz"
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(named: usdzPath)
        .sink(receiveCompletion: { error in
            debugLog(object:"Error while reading usdz file: \(error)")
          cancellable?.cancel()
        }, receiveValue: { modelEntity in
            self.placeModel(modelEntity: modelEntity, position: position)
          cancellable?.cancel()
        })
    }
    
    func placeModel(modelEntity:ModelEntity,position: SIMD3<Float>){
        let anchorEntity = MyEntity()
        anchorEntity.position = position
        anchorEntity.name = "tentAnchor"
        anchorEntity.addChild(modelEntity)
        anchorEntity.generateCollisionShapes(recursive: true)
        self.installGestures([.rotation,.translation],for: anchorEntity)
        self.scene.addAnchor(anchorEntity)
    }
}

//MARK: -- RELEASE RESOURCES
extension ARView{
    
    func removeModel(){
        if let anchorEntity = self.scene.findEntity(named: "tentAnchor"),
           let modelEntity = anchorEntity.children.first{
            modelEntity.removeFromParent()
            anchorEntity.removeFromParent()
        }
    }
    
    func kill() {
        self.session.pause()
        self.scene.anchors.removeAll()
        self.removeFromSuperview()
    }
    
    func pause(){
        self.session.pause()
    }
}

