//
//  NavigationViewModifier.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//
import SwiftUI
struct NavigationViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        .vCenter()
        .hCenter()
        .scrollContentBackground(.hidden)
        .background( Color.background )
    }
}
