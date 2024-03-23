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


struct SectionFoldableHeavy<Header:View,Content: View,T:Comparable>: View{
    let header:Header
    let content:Content
    let splitColor:Color
    let toggleColor:Color
    let onLabelText:String
    let offLabelText:String
    @Binding var automaticFold:T?
    @State var showContent:Bool = false
    var addedSplitLine:Bool = false
    
    var body: some View {
        Section {
            ZStack{
                if showContent && automaticFold != nil{
                    content
                }
                else if addedSplitLine{
                    SplitLine(color:splitColor).hCenter()
                }
            }
        } header: {
            ToggleSectionButtonHeavy(
                      header: header,
                      isOn: $showContent,
                      onLabel: onLabelText,
                      offLabel: offLabelText,
                      color: toggleColor
            )
        } footer: {}
            /*.onChange(of: automaticFold,initial: true){ oldValue,newValue in
                if newValue == nil{
                    withAnimation{
                        showContent = false
                    }
                }
                else{
                    withAnimation{
                        showContent = true
                    }
                }
                
            }*/
    }
}
