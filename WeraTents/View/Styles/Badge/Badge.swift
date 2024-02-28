//
//  Badge.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

struct Badge:View {
    @Binding var count:Int
    
    @ViewBuilder
    var body: some View {
        ZStack{
            Circle().fill(Color.white)
            Text("\(count)")
            .foregroundStyle(Color.red)
            .bold()
         }
        .frame(width: 25.0,height: 25.0)
        .hTrailing()
        .vTop()
        .offset(x:5,y:-11)
        .opacity(count == 0 ? 0 : 1)
        .transition(.move(edge: .top))
    }
}
