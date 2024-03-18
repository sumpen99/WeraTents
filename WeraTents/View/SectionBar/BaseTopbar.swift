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
        VStack{
            HStack{
                BackButtonAction(action: onNavigateBackAction)
                Text(label)
                .font(.headline)
                .bold()
                .foregroundStyle(Color.white)
                .hCenter()
            }
            SplitLine()
        }
        .padding()
   }
}
