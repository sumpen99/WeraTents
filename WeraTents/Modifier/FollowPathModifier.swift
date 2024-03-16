//
//  FollowPathModifier.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-16.
//

import SwiftUI

struct FollowPathModifier:GeometryEffect{
    var pct: CGFloat = 0
    let path: Path
    var rotate = true
    var animatableData: CGFloat {
        get { return pct }
        set { pct = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        if !rotate {
            let pt = percentPoint(pct)
            return ProjectionTransform(CGAffineTransform(translationX: pt.x, y: pt.y))
        } else {
            let pt1 = percentPoint(pct)
            let pt2 = percentPoint(pct - 0.01)
            let a = pt2.x - pt1.x
            let b = pt2.y - pt1.y
            let angle = a < 0 ? atan(Double(b / a)) : atan(Double(b / a)) - Double.pi
            let transform = CGAffineTransform(translationX: pt1.x, y: pt1.y)
                .rotated(by: CGFloat(angle))
            return ProjectionTransform(transform)
        }
    }
    
    func percentPoint(_ percent: CGFloat) -> CGPoint {
        let pct = percent > 1 ? 0 : (percent < 0 ? 1 : percent)
        let f = pct > 0.999 ? CGFloat(1-0.001) : pct
        let t = pct > 0.999 ? CGFloat(1) : pct + 0.001
        let tp = path.trimmedPath(from: f, to: t)
        return CGPoint(x: tp.boundingRect.midX, y: tp.boundingRect.midY)
    }
}
