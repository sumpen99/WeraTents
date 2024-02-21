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
    case place3DModel
    case remove3DModel
    case killSession
   
}

//MARK: -- ACTIONMANAGER
class ActionManager {
    static let shared = ActionManager()
    
    private init() { }
    
    var actionStream = PassthroughSubject<Actions, Never>()
}

//MARK: -- ARVIEW
class ARTentView: ARView {
    var focusEntity: FocusEntity?
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(frame: .zero)
        subscribeToActionStream()
        self.setFocusEntity()
        self.setConfiguration()
    }
    
    func setFocusEntity(){
        self.focusEntity = FocusEntity(on: self, style: .colored(
            onColor: .color(.green),
            offColor: .color(.orange),
            nonTrackingColor: .color(Material.Color.red.withAlphaComponent(0.2))
        ))
    }
    
    func setConfiguration(){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        }
        self.session.run(config)
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
                    strongSelf.removeModel()
                case .killSession:
                    strongSelf.kill()
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

//MARK: -- LOAD MODEL FROM APP
extension ARTentView{
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
}

//MARK: -- RELEASE RESOURCES
extension ARTentView{
    func removeModel(){
        if let anchorEntity = self.scene.findEntity(named: "tentAnchor"),
           let modelEntity = anchorEntity.children.first{
            modelEntity.removeFromParent()
            anchorEntity.removeFromParent()
        }
    }
    
    func kill() {
        DispatchQueue.main.async {
            self.session.pause()
            self.removeModel()
            self.removeFromSuperview()
         }
    }
    
    func pause() async {
        DispatchQueue.main.async {
            self.session.pause()
         }
    }
}

