//
//  ViewExtension.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

extension View{
    func hFill() -> some View{
        self.frame(minWidth: 0, maxWidth: .infinity)
    }
    
    func hLeading() -> some View{
        self.frame(maxWidth: .infinity,alignment: .leading)
    }
    
    func hTrailing() -> some View{
        self.frame(maxWidth: .infinity,alignment: .trailing)
    }
    
    func hCenter() -> some View{
        self.frame(maxWidth: .infinity,alignment: .center)
    }
    
    func vTop() -> some View{
        self.frame(maxHeight: .infinity,alignment: .top)
    }
    
    func vBottom() -> some View{
        self.frame(maxHeight: .infinity,alignment: .bottom)
    }
    
    func vCenter() -> some View{
        self.frame(maxHeight: .infinity,alignment: .center)
    }
}
