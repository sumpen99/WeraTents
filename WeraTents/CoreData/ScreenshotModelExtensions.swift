//
//  ScreenshotModelExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

extension ScreenshotModel{
    func build(){
        self.id = shortId()
        self.name = "Tent Test"
        self.date = Date()
    }
}
