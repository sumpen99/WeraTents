//
//  GemoteryReader.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

extension GeometryProxy{
    
    func min()->CGFloat{
        self.size.width < self.size.height ? self.size.width : self.size.height
    }
    
    func max()->CGFloat{
        self.size.width > self.size.height ? self.size.width : self.size.height
    }
    
    func boundingRect() ->CGRect{
        CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height)
    }
}
