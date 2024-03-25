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
    
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    init(dRed red:Double,dGreen green:Double,dBlue blue:Double){
        self.init(red: red/255.0,green: green/255.0,blue: blue/255.0)
    }
    
    static var cardColor:Color { return Color(hex: 0x314058)}
    static var lightBackground:Color { return Color(hex:0xecfffd) }
    static var darkBackground:Color { return Color(dRed: 36, dGreen: 36, dBlue: 36) }
    static var darkCardBackground:Color { return Color(dRed: 46, dGreen: 46, dBlue: 46) }
}
