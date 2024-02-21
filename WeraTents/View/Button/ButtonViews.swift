//
//  ButtonViews.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

struct BackButton:View{
    @Environment(\.dismiss) private var dismiss
    var imgLabel:String = "chevron.left"
    var color:Color = Color.white
    var action: (() -> Void)? = nil
    
    var body: some View{
        HStack{
            Button(action:{
                action?()
                dismiss()
            }){
                Image(systemName: imgLabel).font(.headline)
                .foregroundStyle(color)
            }
        }
    }
}
