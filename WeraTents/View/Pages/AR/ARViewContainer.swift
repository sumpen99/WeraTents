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
    @Published var selectedTentMeta:TentMeta?
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
#if targetEnvironment(simulator)
        arView.environment.background = .color(UIColor(Color.background))
#else
        arView.environment.background = .cameraFeed()
#endif
        self.focusEntity = FocusEntity(on: arView, style: .classic())
        self.arView?.setConfiguration()
        self.arView?.session.delegate = self
        
    }
    
    func kill() {
        self.focusEntity?.destroy()
        self.arView?.kill()
        self.arView = nil
        self.focusEntity = nil
    }
    
    func run(){
        DispatchQueue.main.async {
            if let arView = self.arView,
               let configuration = arView.session.configuration{
                arView.session.run(configuration)
                self.setFocusState()
            }
         }
    }
    
    func pause() {
        self.focusEntity?.isEnabled = false
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
    
    func action(_ action:Actions,onResult:((Bool) -> Void)? = nil){
        guard let focusEntity = self.focusEntity else { return }
        switch action {
        case .PLACE_3D_MODEL:
            self.arView?.loadEntityAsync(focusEntity.position){ success,dimensions in
                self.animateModelState(success ? .HAS_MODEL : .HAS_SELECTION)
                self.selectedTentMeta?.setDimension(dimensions)
                onResult?(success)
            }
        case .REMOVE_3D_MODEL:
            self.arView?.removeModel(){ success in
                self.animateModelState(success ? .HAS_SELECTION : self.modelState)
                onResult?(success)
            }
       case .KILL_SESSION:
            self.arView?.kill()
       }
    }
    
    func animateModelState(_ state:ModelState){
        withAnimation{
            self.modelState = state
        }
        self.setFocusState()
    }
    
    /*
    func captureSnapshot(_ callback:((Data?) ->Void)? = nil){ (image) in
         if let image = image,
            let data = image.jpegData(compressionQuality: 1) ?? image.pngData(){
             callback?(data)
         }
         else{
             callback?(nil)
         }
     }*/
    
    func captureSnapshot(_ callback:@escaping (UIImage?) ->Void){
        if let arView = arView{
            arView.snapshot(saveToHDR: false,completion: callback) 
        }
        else{ callback(nil) }
        
    }
    
    func newSelectedTent(_ item:TentMeta){
        self.modelState = selectedTentMeta == nil ? .HAS_SELECTION : self.modelState
        selectedTentMeta = item
        self.setFocusState()
   }
    
    func removeSelectedTent(){
        selectedTentMeta = nil
        self.modelState = .HAS_SELECTION
        setFocusState()
    }
    
    var activeRemoveButton:Bool{
        selectedTentMeta != nil && modelState == .HAS_MODEL
    }
    
    var activeAddButton:Bool{
        selectedTentMeta != nil && modelState == .HAS_SELECTION
    }
    
    var activeCaptureButton:Bool{
        modelState == .HAS_MODEL
    }
    
}

//MARK: -- CONFIGURATION
extension ARView{
    func setConfiguration(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            configuration.sceneReconstruction = .meshWithClassification
        }
        
    }
}

//MARK: -- LOAD MODEL FROM APP
extension ARView{
    func loadEntityAsync(_ position:SIMD3<Float>,onResult:((Bool,TentDimensions?) ->Void)? = nil) {
        let usdzPath = ServiceManager.localUSDZUrl(fileName: "tent-2-man-tent")
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(contentsOf: usdzPath!)
        .sink(receiveCompletion: { error in
            cancellable?.cancel()
            onResult?(false,nil)
        }, receiveValue: { modelEntity in
            self.placeModel(modelEntity: modelEntity, position: position)
            cancellable?.cancel()
            onResult?(true,modelEntity.size())
        })
    }
    
    func placeModel(modelEntity:ModelEntity,position: SIMD3<Float>){
        var smpl = SimpleMaterial()
        smpl.color.tint = .white
       // smpl.metallic = 0.7
       // smpl.roughness = 0.2
                
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

extension ModelEntity {
    func size() -> TentDimensions? {
        guard let mesh = self.model?.mesh else {
            return nil
        }

        let width = mesh.bounds.max.x - mesh.bounds.min.x
        let height = mesh.bounds.max.y - mesh.bounds.min.y
        let depth = mesh.bounds.max.z - mesh.bounds.min.z
        return TentDimensions(width: width, height: height, depth: depth)
    }
}
