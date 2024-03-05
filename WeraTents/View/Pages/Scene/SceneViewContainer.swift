//
//  SceneViewContainer.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-03.
//

import SwiftUI
import SceneKit
import SceneKit.ModelIO

class SceneViewCoordinator: NSObject,SCNSceneRendererDelegate,ObservableObject {
    var scnView:SCNView?
    var usdzData:Data?
    var cameraNode: SCNNode?
    var previousPanPoint: CGPoint?
    var startPanPoint: CGPoint?
    var originalRotation:CGFloat?
    var lastTranslate:CGPoint?
    var prevTranslate:CGPoint?
    var lastTime:TimeInterval?
    var prevTime:TimeInterval?
    
    convenience init(usdzData:Data?){
        self.init()
        self.usdzData = usdzData
    }
    
    func createLightNode() ->SCNNode{
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .area
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        return lightNode
    }
    
    func createCamera() ->SCNCamera{
        let camera = SCNCamera()
        camera.fieldOfView = 10
        camera.automaticallyAdjustsZRange = true
        //camera.usesOrthographicProjection = true
        //camera.orthographicScale = 400
        return camera
    }
    
    func createCameraNode() ->SCNNode{
        let cameraNode = SCNNode()
        return cameraNode
    }
    
    func cameraPosition(boundingBox:(min:SCNVector3,max:SCNVector3),fieldOfView:CGFloat) ->SCNVector3{
        let min = boundingBox.min
        let max = boundingBox.max
        let center = SCNVector3.centerOfVector(v1: min, v2: max)
        let length = SCNVector3.distanceOfLine(v1: min, v2: max,convert:.DEFAULT)
        let theta = (fieldOfView/2).degToRad()
        let adjacentLength = length / Float(tan(theta))
        return SCNVector3(x:0, y:center.y, z:adjacentLength)
    }
    
    func addGesturesToSCNView(_ scnView:SCNView){
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        //self.scnView?.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        scnView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        scnView.addGestureRecognizer(rotationGesture)
    }
    
    func loadTentModel() ->SCNNode?{
        if let url = Bundle.main.url(forResource: "Assets/tent-2-man-tent", withExtension: "usdz") {
            let ass = MDLAsset(url: url)
            ass.loadTextures()
            let tentNode = SCNNode(mdlObject: ass.object(at: 0))
            tentNode.name = "TentNode"
            return tentNode
        }
        return nil
    }
    
    func setSceneView(_ scnView:SCNView){
        if let tentModel = loadTentModel() {
            let scene = SCNScene()
            let boundinBoxNode = SCNNode.createBorderOnBoundingBox(tentModel.boundingBox,
                                       borderColor: UIColor.gray,
                                       textColor: UIColor.white,
                                       addText: true)
            let lightNode = createLightNode()
            let camera = createCamera()
            let cameraNode = createCameraNode()
            cameraNode.camera = camera
            cameraNode.position = cameraPosition(boundingBox: tentModel.boundingBox,
                                                 fieldOfView: camera.fieldOfView)
            cameraNode.orientation = SCNQuaternion(x: 0, y: 0, z: 0, w:0)
            self.cameraNode = cameraNode
        
            tentModel.addChildNode(boundinBoxNode)
            tentModel.addChildNode(lightNode)
            tentModel.addChildNode(cameraNode)
           
            scene.rootNode.addChildNode(tentModel)
            scnView.scene = scene
            scnView.autoenablesDefaultLighting = true
            
            //scnView.allowsCameraControl = true
            
            scnView.pointOfView = cameraNode
            scnView.backgroundColor = UIColor.black
            scnView.delegate = self
            addGesturesToSCNView(scnView)
            self.scnView = scnView
            
        }
        else{
            debugLog(object: "nepp")
        }
    }
    
}

//MARK: SCENEVIEWCOORDINATOR TAP INTERACT
extension SceneViewCoordinator{
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .ended:
            debugLog(object: "Tap On tent or maybe, most probably, most definitely the whole view")
        default:
            break
        }
    }
    
    func toggleDimensionBox(){
        if let tentNode = self.scnView?.scene?.rootNode.find(where: "TentNode"),
           let boxNode = tentNode.find(where: "BoundingBox"){
            boxNode.isHidden = !boxNode.isHidden
        }
    }
}



//MARK: SCENEVIEWCOORDINATOR ROTATE
extension SceneViewCoordinator{
    @objc func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
         switch gestureRecognizer.state {
            case .began:
                originalRotation = gestureRecognizer.rotation
            case .changed:
                transform(currentRotation: gestureRecognizer.rotation)
                self.originalRotation = gestureRecognizer.rotation
             default:
                originalRotation = nil
        }
    }
    
    func transform(currentRotation:CGFloat){
        guard let originalRotation = originalRotation,
              let cameraNode = cameraNode else { return }
        let rotation = transformRotation(originalRot: originalRotation, currentRot: currentRotation)
        cameraNode.transform = SCNMatrix4Mult(cameraNode.transform,rotation)
    }
    
    func transformRotation(originalRot:CGFloat,currentRot:CGFloat) -> SCNMatrix4{
        let newRotation = originalRot-currentRot
        return SCNMatrix4MakeRotation(-Float(newRotation.radToDeg())*0.01, 0, 0.5, 0.5)
    }
}

//MARK: SCENEVIEWCOORDINATOR PINCH
extension SceneViewCoordinator{
    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let camera = cameraNode?.camera else { return }
        let scale = gestureRecognizer.velocity
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            if scale < 0 && camera.fieldOfView >= MAX_ZOOM_LEVEL { return }
            if scale > 0 && camera.fieldOfView <= MIN_ZOOM_LEVEL { return }
            camera.fieldOfView -= CGFloat(scale)*ZOOM_SCALE
        default: break
        }
   }
}

//MARK: SCENEVIEWCOORDINATOR PAN
extension SceneViewCoordinator{
  
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        switch gestureRecognizer.state {
        case .began:
            initializeValues(gestureRecognizer.location(in: view))
        case .changed:
            updateValues()
            transform(gestureRecognizer.location(in: view))
        case .ended:
            setFinalAnimation(gestureRecognizer.location(in: view))
            resetValues()
        default:
            resetValues()
        }
    }
     
    func setFinalAnimation(_ currentP:CGPoint){
        if let lastTranslate = lastTranslate,
           let prevTime = prevTime{
            let seconds = Date().timeIntervalSinceReferenceDate - prevTime;
            let magnitude = sqrt(pow(currentP.x - lastTranslate.x,2) + pow(currentP.y - lastTranslate.y,2))
            if seconds > 0 && magnitude > 0{
                let iSec = 0.01
                let swipeVelocity = CGPointMake((currentP.x - lastTranslate.x) / seconds,
                                                (currentP.y - lastTranslate.y) / seconds)
                let endPoint = CGPointMake(currentP.x + swipeVelocity.x * iSec, currentP.y + swipeVelocity.y * iSec)
                applyAnimation(endPoint)
                
            }
        }
        
    }
    
    func applyAnimation(_ endPoint:CGPoint){
        guard let cameraNode = cameraNode else { return }
        let originalTransform = cameraNode.transform
        transform(endPoint)
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = originalTransform
        cameraNode.addAnimation(animation, forKey: nil)
    }
    
    func transform(_ newPoint: CGPoint) {
        if let previousPoint = previousPanPoint {
            let dx = Float(newPoint.x - previousPoint.x) * ROTATE_SCALE
            let dy = Float(newPoint.y - previousPoint.y) * ROTATE_SCALE
            let dyPTAC = dy * PIXEL_TO_ANGLE
            let dxPTAC = dx * PIXEL_TO_ANGLE
            transformMatrix(by: dxPTAC, and: dyPTAC)
        }
        previousPanPoint = newPoint
    }
    
    func transformMatrix(by dx:Float,and dy:Float){
        let rotateDY = SCNMatrix4MakeRotation(-dy, 1, 0, 0)
        let rotateDX = SCNMatrix4MakeRotation(-dx, 0, 1, 0)
        let rotateMatrix = SCNMatrix4Mult(rotateDY, rotateDX)
        applyTransform(rotateMatrix)
     }
    
    func applyTransform(_ matrix:SCNMatrix4){
        guard let cameraNode = cameraNode else { return }
        let transform = SCNMatrix4Mult(cameraNode.transform, matrix)
        cameraNode.transform = transform
    }
    
    func initializeValues(_ point:CGPoint){
        lastTime = Date().timeIntervalSinceReferenceDate
        prevTime = lastTime
        startPanPoint = point
        previousPanPoint = point
        lastTranslate = previousPanPoint
    }
    
    func updateValues(){
        prevTime = lastTime;
        lastTranslate = previousPanPoint
        lastTime = Date().timeIntervalSinceReferenceDate
    }
    
    func resetValues(){
        prevTime = nil
        lastTime = nil
        lastTranslate = nil
        startPanPoint = nil
        previousPanPoint = nil
    }
    
}

struct SceneViewContainer: UIViewRepresentable {
    typealias UIViewType = SCNView
    typealias Context = UIViewRepresentableContext<SceneViewContainer>
    typealias Coordinator = SceneViewCoordinator
    let sceneViewCoordinator:SceneViewCoordinator
    
    func makeUIView(context: Context) -> UIViewType {
        let scnView = SCNView(frame:.zero)
        sceneViewCoordinator.setSceneView(scnView)
       return scnView
    }
  
    func updateUIView(_ uiView: UIViewType, context: Context){
    }
    
    static func dismantleUIView(_ sceneView: UIViewType, coordinator: Coordinator) {
        //debugLog(object: "dismantleSceneView: \(sceneView.debugDescription)")
    }
    
    func makeCoordinator() -> Coordinator {
        return sceneViewCoordinator
    }
    
    
}

