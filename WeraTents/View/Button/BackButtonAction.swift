//
//  BackButtonAction.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

struct BackButtonAction:View{
    var imgLabel:String = "chevron.left"
    var color:Color = Color.white
    var action: (() -> Void)? = nil
    
    var body: some View{
        Button(action:{ action?() }){
            buttonImage(imgLabel, font: TOP_BAR_FONT, foreground: color)
        }
    }
      
}
