//
//  ScrollSectionBar.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-11.
//

import SwiftUI

struct NavigationSectionBar:View {
    let labelText:String
    let action:() -> Void
    var body: some View {
        content
    }
    
    var content:some View{
        HStack{
            navigationLabel
            navigationButton
        }
        .padding([.horizontal])
    }
    
    var navigationLabel:some View{
        Text(labelText)
        .font(.title)
        .bold()
        .foregroundStyle(Color.white).hLeading()
    }
    
    var navigationButton:some View{
        Button(action: action){
            Image(systemName: "arrow.right")
             .font(.title)
             .bold()
             .foregroundStyle(Color.white)
        }
    }
}
