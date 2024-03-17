//
//  Badge.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

struct Badge: ViewModifier {
    @Binding var count:Int
    
    @ViewBuilder
    func body(content: Content) -> some View {
        ZStack {
            content
            .overlay{
                if count > 0{
                    badgeView
                }
            }
        }
     }
     
    var badgeView: some View {
        ZStack{
            Circle().fill(Color.lightBrown)
            Text("\(count)")
            .foregroundStyle(Color.lightGold)
            .bold()
         }
        .frame(width: 25.0,height: 25.0)
        .hTrailing()
        .vTop()
        .offset(x:5,y:-11)
        .animation(.bouncy, value: count)
    }
}
