//
//  BaseTopbar.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-11.
//

import SwiftUI

struct BaseTopBar:View {
    let label:String
    let onNavigateBackAction:() -> Void
    
    var body: some View {
        topBar
    }
    
    var topBar:some View{
        HStack{
            BackButtonAction(action: onNavigateBackAction)
            Text(label)
            .font(.headline)
            .bold()
            .frame(height: 33)
            .foregroundStyle(Color.white)
            .hCenter()
            .padding([.vertical],5)
        }
        .hLeading()
    }
}
