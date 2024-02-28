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

enum ModelState{
    case HAS_EMPTY
    case HAS_SELECTION
    case HAS_MODEL
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
    @Published var modelState:ModelState = .HAS_EMPTY
    @Published var selectedTent:TentItem?
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
        setFocusState()
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
    
    func setFocusState(){
        switch self.modelState {
        case .HAS_EMPTY:
            self.focusEntity?.isEnabled = false
        case .HAS_SELECTION:
            self.focusEntity?.isEnabled = true
        case .HAS_MODEL:
            self.focusEntity?.isEnabled = false
        }
    }
    
    func action(_ action:Actions){
        guard let focusEntity = self.focusEntity else { return }
        switch action {
        case .PLACE_3D_MODEL:
            self.arView?.loadEntityAsync(focusEntity.position){ success in
                self.modelState = success ? .HAS_MODEL : .HAS_SELECTION
                self.setFocusState()
            }
        case .REMOVE_3D_MODEL:
            self.arView?.removeModel(){ result in
                if result{
                    self.modelState = .HAS_SELECTION
                }
                self.setFocusState()
            }
       case .KILL_SESSION:
            self.arView?.kill()
       }
    }
    
    /*
    func captureSnapshot(_ callback:((Data?) ->Void)? = nil){
        self.arView?.snapshot(saveToHDR: false) { (image) in
            if let image = image,
               let pngImage = image.pngData(),
               let compressedImage = UIImage(data: pngImage){
                callback?(compressedImage)
                return
            }
        }
        callback?(nil)
    }*/
    
    func captureSnapshot(_ callback:((Data?) ->Void)? = nil){
        self.arView?.snapshot(saveToHDR: false) { (image) in
            if let image = image,
               let data = image.jpegData(compressionQuality: 1) ?? image.pngData(){
                callback?(data)
                return
            }
        }
        callback?(nil)
    }
    
    func newSelectedTent(_ item:TentItem){
        self.modelState = selectedTent == nil ? .HAS_SELECTION : self.modelState
        selectedTent = item
        self.setFocusState()
   }
    
    func removeSelectedTent(){
        selectedTent = nil
        self.modelState = .HAS_SELECTION
        setFocusState()
    }
    
    var activeRemoveButton:Bool{
        selectedTent != nil && modelState == .HAS_MODEL
    }
    
    var activeAddButton:Bool{
        selectedTent != nil && modelState == .HAS_SELECTION
    }
    
    var activeCaptureButton:Bool{
        modelState == .HAS_MODEL
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
    func loadEntityAsync(_ position:SIMD3<Float>,onResult:((Bool) ->Void)? = nil) {
        let usdzPath = "Assets/tent-2-man-tent.usdz"
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(named: usdzPath)
        .sink(receiveCompletion: { error in
            debugLog(object:"Error while reading usdz file: \(error)")
          cancellable?.cancel()
            onResult?(false)
        }, receiveValue: { modelEntity in
            self.placeModel(modelEntity: modelEntity, position: position)
          cancellable?.cancel()
            onResult?(true)
        })
    }
    
    func placeModel(modelEntity:ModelEntity,position: SIMD3<Float>){
        var smpl = SimpleMaterial()
        smpl.color.tint = .blue
        smpl.metallic = 0.7
        smpl.roughness = 0.2
                
        var pbr = PhysicallyBasedMaterial()
        pbr.baseColor.tint = .green
        
        modelEntity.model?.materials = [smpl,pbr]
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
    
    func removeModel(onResult:((Bool) ->Void)? = nil){
        if let anchorEntity = self.scene.findEntity(named: "tentAnchor"),
           let modelEntity = anchorEntity.children.first{
            modelEntity.removeFromParent()
            anchorEntity.removeFromParent()
            onResult?(true)
            return
        }
        onResult?(false)
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

