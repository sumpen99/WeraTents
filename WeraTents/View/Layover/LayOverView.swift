//
//  LayOverView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct LayOverView:View {
    @Binding var closeView:Bool
    var body: some View {
        content
        .onTapGesture {
            withAnimation{
                closeView.toggle()
            }
        }
    }
    
    var content: some View{
        ZStack{
            Color.white.opacity(0.5)
        }
        .ignoresSafeArea(.all)
        .vTop()
        .hCenter()
    }
}
