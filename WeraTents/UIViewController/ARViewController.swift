//
//  ARViewController.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//
import SwiftUI
import RealityKit
import ARKit
import FocusEntity
import Combine
struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> TentARView {
        return TentARView()
    }
    
    func updateUIView(_ uiView: TentARView, context: Context) {}
}

class MyEntity: Entity, HasAnchoring, HasModel, HasCollision {
    
}

class TentARView: ARView {
    let radians = Float.pi/2.0
    var focusEntity: FocusEntity?
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(frame: .zero)
        
        // ActionStrean
        subscribeToActionStream()
        
        // FocusEntity
        self.focusEntity = FocusEntity(on: self, style: .colored(
            onColor: .color(.green),
            offColor: .color(.orange),
            nonTrackingColor: .color(Material.Color.red.withAlphaComponent(0.2))
        ))
        
        // Configuration
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        }
        self.session.run(config)
    }

    
    func place3DModel() {
        guard let focusEntity = self.focusEntity else { return }

        guard let modelEntity = try? ModelEntity.load(
          named: "Assets/tent-2-man-tent.usdz"
        ) else { fatalError("Cannot load model") }
        
        
        let anchorEntity = MyEntity()
        anchorEntity.position = focusEntity.position
        anchorEntity.name = "tentAnchor"
        anchorEntity.addChild(modelEntity)
        //anchorEntity.transform = Transform.identity
        //anchorEntity.transform.translation.z -= 0.3
        
        /*let boxShape = ShapeResource.generateBox(width: 1000, height: 1000, depth: 1000)
        let boxShapeCollisionComponent = CollisionComponent (
          shapes: [boxShape],
          mode: .trigger,
          filter: .default
        )
        anchorEntity.collision = boxShapeCollisionComponent*/
        anchorEntity.generateCollisionShapes(recursive: true)
        self.installGestures([.rotation,.translation],for: anchorEntity)
       
        //let anchorEntity = AnchorEntity(world: focusEntity.position)
        //anchorEntity.addChild(myEntity)
        //anchorEntity.name = "tentAnchor"
        //let radians = 180.0 * Float.pi / 180.0
        //modelEntity.transform.rotation += simd_quatf(angle: GLKMathDegreesToRadians(180), axis: SIMD3(x: 0, y: 1, z: 0))
        //modelEntity.transform.translation += SIMD3<Float>(0.0, 1.0, 0.0)  // This is Meters!!!  not CM.
        //modelEntity.transform.rotation += simd_quatf(angle: radians, axis: SIMD3<Float>(0,1,0))
        //modelEntity.orientation = simd_quatf(angle: radians, axis: SIMD3(x: 0, y: 1, z: 1))
        //modelEntity.transform.scale *= 0.5
        self.scene.addAnchor(anchorEntity)
    }
    
    func loadEntityAsync() {
        guard let focusEntity = self.focusEntity else { return }
        let anchorEntity = MyEntity()
        anchorEntity.position = focusEntity.position
        anchorEntity.name = "tentAnchor"
        self.scene.addAnchor(anchorEntity)
   
        let usdzPath = "Assets/tent-2-man-tent.usdz"
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(named: usdzPath)
        .sink(receiveCompletion: { error in
          print("Unexpected error: \(error)")
          cancellable?.cancel()
        }, receiveValue: { modelEntity in
            anchorEntity.addChild(modelEntity)
          cancellable?.cancel()
        })
    }
    
    
    func subscribeToActionStream() {
        ActionManager.shared
            .actionStream
            .sink { [weak self] action in
                guard let strongSelf = self else{ return }
                switch action {
                    
                case .place3DModel:
                    strongSelf.loadEntityAsync()
                    
                case .remove3DModel:
                    if let anchorEntity = strongSelf.scene.findEntity(named: "tentAnchor"),
                       let modelEntity = anchorEntity.children.first{
                        modelEntity.removeFromParent()
                        anchorEntity.removeFromParent()
                    }
                case .rotate3DModelPitch:
                    if let modelEntity = strongSelf.scene.findEntity(named: "tentModel"){
                        modelEntity.move(to: .init(pitch: strongSelf.radians), relativeTo: modelEntity,
                                         duration: 0.3, timingFunction: .linear)
                    }
                case .rotate3DModelYaw:
                    if let modelEntity = self?.scene.findEntity(named: "tentModel"){
                        modelEntity.move(to: .init(yaw: strongSelf.radians), relativeTo: modelEntity,
                                         duration: 0.3, timingFunction: .linear)
                   }
                case .rotate3DModelRoll:
                    if let modelEntity = self?.scene.findEntity(named: "tentModel"){
                        modelEntity.move(to: .init(roll: -0.05), relativeTo: modelEntity,
                                         duration: 0.3, timingFunction: .linear)
                   }
               }
                
                
            }
            .store(in: &cancellables)
    }
    
    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
}

enum Actions {
    case place3DModel
    case remove3DModel
    case rotate3DModelPitch
    case rotate3DModelYaw
    case rotate3DModelRoll
}

class ActionManager {
    static let shared = ActionManager()
    
    private init() { }
    
    var actionStream = PassthroughSubject<Actions, Never>()
}
