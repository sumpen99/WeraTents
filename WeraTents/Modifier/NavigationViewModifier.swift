//
//  NavigationViewModifier.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//
import SwiftUI
struct NavigationViewModifier: ViewModifier {
    let color:UIColor
    var title:String = ""
    func body(content: Content) -> some View {
        content
        .vCenter()
        .hCenter()
        .scrollContentBackground(.hidden)
        .background( Color(uiColor: color) )
        .navigationBarTitle(title,displayMode: .inline)
    }
}
