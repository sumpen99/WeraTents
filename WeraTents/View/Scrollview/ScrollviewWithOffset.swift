//
//  ScrollviewWithOffset.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

extension ScrollView {

    func withOffsetTracking(action: @escaping (CGPoint) -> Void) -> some View {
        self.coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ScrollViewWithOffset<Content: View>: View {
   let onScroll: ((CGPoint) -> Void)
   let content: () -> Content

    var body: some View {
        ScrollView{
            ZStack{
                tracker
                content()
            }
        }
        .withOffsetTracking(action: onScroll)
    }
    
    var tracker:some View{
        GeometryReader { reader in
            Color.clear
            .preference(
                key: ScrollOffsetPreferenceKey.self,
                value: reader.frame(in: .named("scrollView")).origin
            )
        }
        .frame(height: 0)
    }
}
