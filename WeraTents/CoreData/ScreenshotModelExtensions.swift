//
//  ScreenshotModelExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

extension ScreenshotModel{
    func buildWithName(_ meta:TentMeta?){
        if let meta = meta{
            self.id = shortId(length: 6)
            self.name = meta.name
            self.label = meta.label
            self.shortDesc = meta.shortDesc
            self.modelId = meta.modelId
            self.date = Date()
            if let dimensions = meta.dimensions{
                self.width = dimensions.width
                self.height = dimensions.height
                self.depth = dimensions.depth
            }
        }
        
    }
}
