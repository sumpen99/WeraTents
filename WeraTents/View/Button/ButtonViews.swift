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
    var color:Color = Color.black
    var action: (() -> Void)? = nil
    
    var body: some View{
        Button(action:backAction){ label }
    }
    
    var label:some View{
        Image(systemName: imgLabel)
        .font(.largeTitle)
        .imageScale(.medium)
        .bold()
        .foregroundStyle(color)
    }
    
    func backAction(){
        action?()
        dismiss()
    }
}
