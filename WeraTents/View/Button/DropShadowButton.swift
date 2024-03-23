//
//  DropShadowButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-11.
//

import SwiftUI

struct DropShadowButton:View {
    let buttonText:String
    let frameWidth:CGFloat
    let action:() -> Void
    var body: some View {
        Button(action: action, label: {
            content
        })
    }
    
    var content:some View{
        ZStack{
            Color.lightGold
            Text(buttonText)
            .foregroundStyle(Color.white)
            .bold()
            .shadow(color: Color.materialDarkest, radius: 5, x: 0, y: 5)
        }
        .frame(width: calculatedWidth())
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_BRAND))
        .shadow(color:Color.lightGold,radius: 2.0)
        .padding()
    }
    
    func calculatedWidth() -> CGFloat{
        let width = (frameWidth-V_SPACING_REG)/4
        return width < 0 ? 0 : width
    }
}
