//
//  ScrollviewLabelHeader.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct ScrollviewLabelHeader:View {
    let namespace:Namespace.ID
    let thickness:CGFloat
    @Binding var bindingLabel:String?
    @Binding var bindingList:[String]
    
    var body: some View {
        content
        .frame(height:MENU_HEIGHT)
        .scrollIndicators(.never)
    }
    
    var content:some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .center, spacing: 20, pinnedViews: [.sectionHeaders]){
                ForEach(bindingList, id: \.self) { label in
                    SelectedHeader(namespace: namespace,
                                   namespaceName: "CURRENT_SELECTED_HEADER",
                                   label: label,
                                   thickness: thickness,
                                   bindingLabel: $bindingLabel)
               }
            }
            .padding()
        }
    }
}
