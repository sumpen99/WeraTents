//
//  ARExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-01.
//

import SwiftUI
import ARKit

enum ScnVectorDistance:SCNFloat{
    case DEFAULT = 1.0
    case CENTIMETER = 100.0
    case METER = 1000.0
}

//MARK: - AR TEXTNODE
class ARTextNode:SCNNode{
    var pos1:SCNVector3?
    var pos2:SCNVector3?
    var shift:Bool = false
          
    convenience init(pos1: SCNVector3,
                     pos2:SCNVector3,
                     shift:Bool,
                     color:UIColor){
        let distance = SCNVector3.distanceOfLine(v1: pos1, v2: pos2, convert: .DEFAULT)
        let text = String(format: "%.2f cm", distance)
        let textGeometry = SCNText(string: "\(text)\n", extrusionDepth: 1)
        textGeometry.font = UIFont.boldSystemFont(ofSize: 6)
        textGeometry.firstMaterial?.diffuse.contents = color
        self.init()
        textGeometry.firstMaterial?.lightingModel = .constant
        textGeometry.firstMaterial?.isDoubleSided = true
        textGeometry.flatness = 0
        self.geometry = textGeometry
        self.pos1 = pos1
        self.pos2 = pos2
        self.shift = shift
        self.centerAlign()
     }
    
    
    
    func centerAlign(){
        translatePivot()
        simdScale()
        centerPosition()
        rotateRadians()
        shiftAction()
    }
  
    func translatePivot(){
        let min = boundingBox.min
        let max = boundingBox.max
        pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }
    
    func simdScale(){
        simdScale = SIMD3<Float>(repeating:0.5)
    }
     
    func centerPosition(){
        if let pos1 = pos1,
           let pos2 = pos2{
            let center = SCNVector3.centerOfVector(v1: pos1, v2: pos2)
            position = center
            
        }
    }
   
    func rotateRadians(){
        if let pos1 = pos1,
           let pos2 = pos2{
            let radians = SCNVector3.angleOfLine(v1: pos1, v2: pos2)
            if radians == SCNFloat.pi{
                rotation = SCNVector4(0, 0, 1, radians/2.0)
                position.x -= 1.5
            }
            else{
                rotation = SCNVector4(0, 1, 0, radians)
                position.y += 1.5
            }
        }
    }
    
    func shiftAction(){
        if shift{
            let action = SCNAction.rotateBy(x: 0, y: -CGFloat(180).degToRad(), z: 0, duration: 0)
            runAction(action)
        }
    }
      
}

//MARK: - SCNNODE
extension SCNNode {
    static func createCylinderLine(from: simd_float3, 
                                   to: simd_float3,
                                   radius : CGFloat = 0.25,
                                   color:UIColor) -> SCNNode{
        let vector = to - from
        let height = simd_length(vector)

        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
        //cylinder.firstMaterial?.diffuse.contents = color
        //cylinder.firstMaterial?.isDoubleSided = true
        let material = SCNMaterial()
        material.diffuse.contents = color
        //material.isDoubleSided = true
        //material.ambient.contents = UIColor.yellow
        material.lightingModel = .constant
        cylinder.materials = [material]
         
        let lineNode = SCNNode(geometry: cylinder)

        let line_axis = simd_float3(0, height/2, 0)
        lineNode.simdPosition = from + line_axis

        let vector_cross = simd_cross(line_axis, vector)
        let qw = simd_length(line_axis) * simd_length(vector) + simd_dot(line_axis, vector)
        let q = simd_quatf(ix: vector_cross.x, iy: vector_cross.y, iz: vector_cross.z, r: qw).normalized

        lineNode.simdRotate(by: q, aroundTarget: from)
        return lineNode
    }
    
    static func createLineNode(fromPos origin: SCNVector3, toPos destination: SCNVector3, color: UIColor) -> SCNNode {
        let line = lineFrom(vector: origin, toVector: destination)
        let lineNode = SCNNode(geometry: line)
        line.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(1.0)
      
        return lineNode
    }
    
    static func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]

        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)

        return SCNGeometry(sources: [source], elements: [element])
    }
    
    static func createBorderOnNode(_ node:SCNNode,
                                   borderColor:UIColor,
                                   textColor:UIColor,
                                   addText:Bool = true){
        let bbox = node.boundingBox
        let min = bbox.min
        let max = bbox.max
      
        let p0 = simd_float3(x: min.x, y: min.y, z: min.z)
        let p1 = simd_float3(x: min.x, y: min.y, z: max.z)
        let p2 = simd_float3(x: max.x, y: min.y, z: max.z)
        let p3 = simd_float3(x: max.x, y: min.y, z: min.z)
        
        let p4 = simd_float3(x: p0.x, y: max.y, z: p0.z)
        let p5 = simd_float3(x: p1.x, y: max.y, z: p1.z)
        let p6 = simd_float3(x: p2.x, y: max.y, z: p2.z)
        let p7 = simd_float3(x: p3.x, y: max.y, z: p3.z)
        let indices:[simd_float3] = [p0,p1,p2,p3,p4,p5,p6,p7]
        for i in 0..<indices.count{
            let shift = i == 3||i == 7
            let p1 = indices[i]
            let p2 = shift ? indices[i-3] : indices[i+1]
            let lineBase = SCNNode.createCylinderLine(from: p1,to: p2,color:borderColor)
            node.addChildNode(lineBase)
            if addText{
                let textNode = ARTextNode(pos1: SCNVector3(x: p1.x, y: p1.y, z: p1.z),
                                          pos2: SCNVector3(x: p2.x, y: p2.y, z: p2.z),
                                          shift: shift,
                                          color:textColor)
                node.addChildNode(textNode)
            }
            if i < 4 {
                let p3 = indices[i+4]
                let lineDiagonal = SCNNode.createCylinderLine(from: p1,to: p3,color: borderColor)
                node.addChildNode(lineDiagonal)
                if addText{
                    let textDiagonal = ARTextNode(pos1: SCNVector3(x: p1.x, y: p1.y, z: p1.z),
                                              pos2: SCNVector3(x: p3.x, y: p3.y, z: p3.z),
                                                  shift: i == 0||i == 3,
                                                  color:textColor)
                    node.addChildNode(textDiagonal)
                }
                
            }
        }
           
    }
    
}

//MARK: - CGFLOAT
extension CGFloat{
  
    func degToRad() -> CGFloat{
        return self * (CGFloat.pi/180.0)
    }
    
    func radToDeg() -> CGFloat{
        return self * (180.0/CGFloat.pi)
    }
}

//MARK: - SCNVECTOR3
extension SCNVector3{
    static func distanceOfLine(v1: SCNVector3,v2: SCNVector3,convert to:ScnVectorDistance = .DEFAULT) -> SCNFloat {
        let dx = v1.x - v2.x
        let dy = v1.y - v2.y
        let dz = v1.z - v2.z
        var distance = SCNFloat(sqrt(dx*dx + dy*dy + dz*dz))
        distance *= to.rawValue
    
        return abs(distance)
    }
    
    static func centerOfVector(v1:SCNVector3, v2:SCNVector3) -> SCNVector3{
        return SCNVector3((v1.x + v2.x) / 2.0, (v1.y + v2.y) / 2.0 , (v1.z + v2.z) / 2.0)
    }
    
    static func angleOfLine(v1:SCNVector3, v2:SCNVector3) -> SCNFloat{
      let d = SCNVector3.diff(v1:v1,v2:v2)
      let theta = atan2(d.z, d.x)
      return SCNFloat.pi - theta
    }
    
    static func diff(v1:SCNVector3,v2:SCNVector3) ->SCNVector3{
        if v1.x > v2.x {
            return SCNVector3(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z)
        }
        else{
           return SCNVector3(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
        }
     }
}
