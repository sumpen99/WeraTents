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
    var selectedTent:Tent?
    var currentModelUrl:URL?
    @Published var modelState:ModelState = .HAS_EMPTY
  
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        /*if let objectPosition = focusEntity?.position{
            //let transform = frame.camera.transform.columns.3
            //let devicePosition = simd_float3(x: transform.x, y: transform.y, z: transform.z)
            //let objectPosition = node.simdWorldPosition
            //let distance = distance(devicePosition,objectPosition)
            //debugLog(object:distance)
            /*
             let hitTestResults = sceneView.hitTest(sceneView.center,types:[.existingPlaneUsingGeometry])
             guard let result = hitTestResults.first else { return nil }
             let hitCoordinates = simd_float3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)

             let distance = distance(cameraCoordinates,hitCoordinates)
             */
        }*/
        
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
        self.setFocusState()
        self.arView?.session.delegate = self
    }
    
    func run(){
        if let arView = arView{
            arView.configurateAndRun()
        }
    }
    
    func kill() {
        self.focusEntity?.destroy()
        self.arView?.kill()
        self.arView = nil
        self.focusEntity = nil
    }
     
    func pause() {
        self.focusEntity?.isEnabled = false
        self.arView?.pause()
    }
    
    
    func action(_ action:Actions,onResult:((Bool) -> Void)? = nil){
        guard let focusEntity = self.focusEntity else { return }
        switch action {
        case .PLACE_3D_MODEL:
            self.arView?.loadEntityAsync(focusEntity.position,
                                         fileUrl: currentModelUrl){ success,meta in
                self.animateModelState(success ? .HAS_MODEL : .HAS_SELECTION)
                self.selectedTent?.meta = meta
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
    
    func captureSnapshot(_ callback:@escaping (UIImage?) ->Void){
        if let arView = arView{
            arView.snapshot(saveToHDR: false,completion: callback) 
        }
        else{ callback(nil) }
        
    }
    
    func newSelectedTent(_ tent:Tent,modelURL:URL){
        self.modelState = .HAS_SELECTION
        self.selectedTent = tent
        self.currentModelUrl = modelURL
        self.setFocusState()
    }
    
    func removeSelectedTent(){
        selectedTent = nil
        self.modelState = .HAS_EMPTY
        self.arView?.removeModel()
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
    
}

//MARK: -- CONFIGURATION
extension ARView{
    
    func configurateAndRun(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            configuration.sceneReconstruction = .meshWithClassification
        }
        self.session.run(configuration)
    }
    
    func disablePlaneDetection(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []
        configuration.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            configuration.sceneReconstruction = .meshWithClassification
        }
        self.session.run(configuration)
        
    }
}

//MARK: -- LOAD MODEL FROM APP
extension ARView{
    func loadEntityAsync(_ position:SIMD3<Float>,fileUrl:URL?,onResult:((Bool,Meta?) ->Void)? = nil) {
        if let usdzPath = fileUrl{
            var cancellable: AnyCancellable? = nil
            cancellable = ModelEntity.loadModelAsync(contentsOf: usdzPath)
            .sink(receiveCompletion: { error in
                cancellable?.cancel()
                onResult?(false,nil)
            }, receiveValue: { [weak self] modelEntity in
                self?.placeModel(modelEntity: modelEntity, position: position)
                cancellable?.cancel()
                onResult?(true,modelEntity.size())
            })
        }
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
        //let radians = 180.0 * Float.pi / 180.0
        modelEntity.transform.translation -= SIMD3<Float>(0.0, 0.37835, 0.0)
        //modelEntity.orientation = simd_quatf(angle: radians, axis: SIMD3(x: 0, y: 1, z: 0))
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
    func size() -> Meta? {
        guard let mesh = self.model?.mesh else {
            return nil
        }

        let width = mesh.bounds.max.x - mesh.bounds.min.x
        let height = mesh.bounds.max.y - mesh.bounds.min.y
        let depth = mesh.bounds.max.z - mesh.bounds.min.z
        return Meta(width: width, height: height, depth: depth)
    }
}
