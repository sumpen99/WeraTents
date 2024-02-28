//
//  ShapeMenu.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

struct BatmanShapeMenu: Shape {
   func path(in rect: CGRect) -> Path {
       let y_middle = MENU_HEIGHT/2.0
       let part = CORNER_RADIUS_MENU*1.5
       let middle = rect.maxX/2.0
       let start = middle-part
       let end = middle+part
       let offY = MENU_HEIGHT*0.8667
       let minY = MENU_HEIGHT*0.1333
       let midOffY = MENU_HEIGHT*0.2333
     return Path { path in
         path.move(to: CGPoint(x: end, y: 0))
         path.addQuadCurve(to: CGPoint(x: rect.maxX-CORNER_RADIUS_MENU,y:0), control: CGPoint(x:rect.maxX-part, y: minY))
         path.addQuadCurve(to: CGPoint(x: rect.maxX-CORNER_RADIUS_MENU, y: MENU_HEIGHT), control: CGPoint(x:rect.maxX, y: y_middle))
         path.addQuadCurve(to: CGPoint(x: end,y:MENU_HEIGHT), control: CGPoint(x:rect.maxX-part, y: offY))
         path.addQuadCurve(to: CGPoint(x: start,y:MENU_HEIGHT), control: CGPoint(x:middle, y: MENU_HEIGHT+midOffY))
         path.addQuadCurve(to: CGPoint(x: CORNER_RADIUS_MENU,y:MENU_HEIGHT), control: CGPoint(x:part, y: offY))
         path.addQuadCurve(to: CGPoint(x: CORNER_RADIUS_MENU,y:0), control: CGPoint(x:0, y: y_middle))
         path.addQuadCurve(to: CGPoint(x: start,y:0), control: CGPoint(x:part, y: MENU_HEIGHT-offY))
         path.addQuadCurve(to: CGPoint(x: end,y:0), control: CGPoint(x:middle, y: -midOffY))
         }
    }
    
}

struct OvalShapeMenu: Shape {
   func path(in rect: CGRect) -> Path {
       let part = CORNER_RADIUS_MENU*1.5
       let middle = rect.maxX/2.0
       let start = middle-part
       let end = middle+part
     return Path { path in
         path.move(to: CGPoint(x: start, y: 0))
         path.addQuadCurve(to: CGPoint(x: end,y:0), control: CGPoint(x:middle, y: -CORNER_RADIUS_MENU/2.0))
         //path.move(to: CGPoint(x: start, y: MENU_HEIGHT))
         //path.addQuadCurve(to: CGPoint(x: end,y:MENU_HEIGHT), control: CGPoint(x:middle, y: MENU_HEIGHT+CORNER_RADIUS_MENU))
         }
    }
    
}

struct OvalShapeMenuButton: Shape {
   func path(in rect: CGRect) -> Path {
       let part = CORNER_RADIUS_MENU*1.5
       let middle = rect.maxX/2.0
       let start = middle-part
       let end = middle+part
     return Path { path in
         path.move(to: CGPoint(x: start, y: 0))
         path.addQuadCurve(to: CGPoint(x: end,y:0), control: CGPoint(x:middle, y: -CORNER_RADIUS_MENU))
         path.addLine(to: CGPoint(x: end, y: rect.maxY))
         path.addLine(to: CGPoint(x: start, y: rect.maxY))
         path.addLine(to: CGPoint(x: start, y: 0))
         //path.move(to: CGPoint(x: start, y: MENU_HEIGHT))
         //path.addQuadCurve(to: CGPoint(x: end,y:MENU_HEIGHT), control: CGPoint(x:middle, y: MENU_HEIGHT+CORNER_RADIUS_MENU))
         }
    }
    
}
