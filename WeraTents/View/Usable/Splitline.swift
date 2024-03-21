//
//  Splitline.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-12.
//

import SwiftUI

enum SplitDirection{
    case HORIZONTAL
    case VERTICAL
}

struct SplitLine:View {
    var direction:SplitDirection = .HORIZONTAL
    var color:Color = Color.lightGold
    var thickness:CGFloat = 1.0
    
    var body: some View {
        switch direction {
        case .HORIZONTAL:
            hSplit
        case .VERTICAL:
            vSplit
        }
    }
    
    var hSplit: some View{
        Capsule()
        .fill(color)
        .frame(height: thickness)
        .hCenter()
    }
    
    var vSplit: some View{
        Rectangle()
        .fill(color)
        .frame(width: thickness)
        .vCenter()
    }
}
