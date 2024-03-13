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
    @State var scaleAmount:CGFloat = 1.0
    
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
                                   label: label,
                                   thickness: thickness,
                                   bindingLabel: $bindingLabel)
               }
            }
            .padding()
        }
    }
}
