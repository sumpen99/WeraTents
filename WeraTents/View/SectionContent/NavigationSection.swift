//
//  NavigationSection.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-11.
//

import SwiftUI

struct NavigationSection<Content:View>:View {
    let labelText:String
    let action:() -> Void
    let content:Content
    let backgroundColor:Color
    
    var body: some View {
        mainContent
    }
    
    var mainContent:some View{
        VStack{
            NavigationSectionBar(labelText: labelText,action: action)
            SplitLine(color:Color.lightGold)
            content
         }
        .padding(.vertical)
        .background{
            backgroundColor
        }
    }
}
