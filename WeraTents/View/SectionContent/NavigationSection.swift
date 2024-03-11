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
    
    var body: some View {
        mainContent
    }
    
    var mainContent:some View{
        VStack{
            NavigationSectionBar(labelText: labelText,action: action)
            content
         }
    }
}
