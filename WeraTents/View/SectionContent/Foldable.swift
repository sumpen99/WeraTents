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


struct SectionFoldableHeavy<Header:View,Content: View>: View{
    let header:Header
    let content:Content
    let splitColor:Color
    let toggleColor:Color
    @State var showContent:Bool = false
    var body: some View {
        Section {
            ZStack{
                if showContent{ content }
                else{ SplitLine(color:splitColor).vBottom().hCenter() }
            }
            
        } header: {
            ToggleSectionButtonHeavy(
                      header: header,
                      isOn: $showContent,
                      onLabel: "Dölj",
                      offLabel: "Visa mer",
                      color: toggleColor
            )
        } footer: {}
    }
}
