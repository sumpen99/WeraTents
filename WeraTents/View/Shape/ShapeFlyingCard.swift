//
//  ShapeFlyingCard.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-16.
//

import SwiftUI

struct ShapeFlyingCard: Shape {
 
    func path(in rect: CGRect) -> Path {
        return ShapeFlyingCard.createPath(in: rect)
    }
    
    static func createPath(in rect: CGRect,shiftPath:Bool = false) -> Path {
        let centerX = rect.size.width/2.0
        let centerY = rect.size.height/2.0
        let controlX1 = shiftPath ? centerX*1.5 : centerX/2.0
        let controlX2 = shiftPath ? centerX/2.0 : centerX*1.5
        let startY = rect.size.height
    
        var path = Path()
        path.move(to: CGPoint(x:centerX, y: startY))
        path.addCurve(to: CGPoint(x:centerX, y: startY*0.80),
                      control1: CGPoint(x:controlX1, y: startY*0.95),
                      control2: CGPoint(x:controlX1, y: startY*0.85))
        path.addCurve(to: CGPoint(x:centerX, y: startY*0.60),
                      control1: CGPoint(x:controlX2, y: startY*0.75),
                      control2: CGPoint(x:controlX2, y: startY*0.65))
        path.addCurve(to: CGPoint(x:centerX, y: centerY),
                      control1: CGPoint(x:centerX, y: startY*0.575),
                      control2: CGPoint(x:centerX, y: startY*0.55))
        return path
    }
    
    /*
    static func createPath(in rect: CGRect,indexCount:Int = 1) -> Path {
        let padding:CGFloat = 20.0
        
        let centerX = rect.size.width/2.0
        let centerY = rect.size.height/2.0
        
        let endX = rect.size.width-padding
        let endY = padding*CGFloat(indexCount)
        
        let controlX1 = centerX
        let controlX2 = rect.size.width*0.9
        
        let controlY = -rect.size.height*0.20
        
        var path = Path()
        path.move(to: CGPoint(x:centerX, y: centerY))
        path.addCurve(to: CGPoint(x:endX, y: endY),
                      control1: CGPoint(x:controlX1, y: controlY),
                      control2: CGPoint(x:controlX2, y: controlY))
        
        /*CENTER -> BOTTOM RIGHT*/
                /*path.move(to: CGPoint(x:centerX, y: centerY))
                path.addCurve(to: CGPoint(x:width, y: height),
                              control1: CGPoint(x:width*0.75, y: height*0.25),
                              control2: CGPoint(x:width*0.95, y: height*0.05))*/
        
        return path
    }*/
}
