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
    }
}
