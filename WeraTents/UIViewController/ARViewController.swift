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

class MyEntity: Entity, HasAnchoring, HasModel, HasCollision {}

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


struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> TentARView {
        return TentARView()
    }
    
    func updateUIView(_ uiView: TentARView, context: Context) {}
}



class TentARView: ARView {
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

    func loadEntityAsync() {
        guard let focusEntity = self.focusEntity else { return }
        let usdzPath = "Assets/tent-2-man-tent.usdz"
        var cancellable: AnyCancellable? = nil
        cancellable = ModelEntity.loadModelAsync(named: usdzPath)
        .sink(receiveCompletion: { error in
            debugLog(object:"Error while reading usdz file: \(error)")
          cancellable?.cancel()
        }, receiveValue: { modelEntity in
            self.placeModel(modelEntity: modelEntity, position: focusEntity.position)
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


