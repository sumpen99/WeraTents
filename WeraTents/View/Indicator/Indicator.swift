//
//  Indicator.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-24.
//

import SwiftUI

struct Indicator:View {
    let cornerRadius:CGFloat
    var backgroundColor:Color = .white
    var indicatorColor:Color = .darkGreen
    let onDragFinnished: (() -> Void)?
    var indicatorDragGesture: some Gesture {
        DragGesture(minimumDistance: 5.0).onChanged{ value in
            withAnimation{
                onDragFinnished?()
           }
        }
   }
    
    var content:some View{
        ZStack{
            RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor)
            Capsule()
            .fill(indicatorColor)
            .frame(width:50.0,height: 6).vTop().padding()
        }
        .frame(height: 25.0)
        .vTop()
        .hCenter()
     }
    
    var body: some View {
        content
        .gesture(indicatorDragGesture)
    }
}
