//
//  ScrollviewLabelHeader.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct ScrollviewLabelHeader:View {
    let namespace:Namespace.ID
    let namespaceName:String
    let thickness:CGFloat
    let bindingList:[String]
    let selectedAnimation:SelectedAnimation
    let menuHeight:CGFloat
    @Binding var bindingLabel:String?
    
    var body: some View {
        content
        .frame(height: menuHeight)
        .scrollIndicators(.never)
    }
    
    var content:some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .center, spacing: 20, pinnedViews: [.sectionHeaders]){
                ForEach(bindingList, id: \.self) { label in
                    SelectedHeader(namespace: namespace,
                                   namespaceName: namespaceName,
                                   label: label,
                                   thickness: thickness,
                                   bindingLabel: $bindingLabel,
                                   selectedAnimation: selectedAnimation)
               }
            }
            .padding()
        }
    }
}
