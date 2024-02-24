//
//  HeaderSubheader.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-24.
//

import SwiftUI

struct SectionFoldable<Content: View>: View{
    let header:String
    let content:Content
    @State var showContent:Bool = true
    var body: some View {
        Section {
            if showContent{
                content
            }
        } header: {
            ToggleSectionButton(
                      title: header,
                      isOn: $showContent,
                      onLabel: "Hide",
                      offLabel: "Show"
                    )
        } footer: {}
     
    }
}
