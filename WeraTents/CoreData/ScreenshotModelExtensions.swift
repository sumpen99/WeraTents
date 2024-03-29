//
//  ScreenshotModelExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

extension ScreenshotModel{
    func buildWithName(_ tent:Tent?){
        if let tent = tent{
            self.name = tent.name
            self.label = tent.label
            self.shortDesc = ""
            self.modelId = tent.modelId
            self.date = Date()
            if let dimensions = tent.meta{
                self.width = dimensions.width
                self.height = dimensions.height
                self.depth = dimensions.depth
            }
        }
        
    }
}
