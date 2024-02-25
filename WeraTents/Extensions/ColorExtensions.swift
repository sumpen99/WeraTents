//
//  ColorExtensions.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-24.
//

import SwiftUI
extension Color{
    static func random() -> Color{
        Color(uiColor: UIColor(red: CGFloat.random(in: 0...1), 
                               green: CGFloat.random(in: 0...1),
                               blue: CGFloat.random(in: 0...1),
                               alpha: 1))
    }
}
