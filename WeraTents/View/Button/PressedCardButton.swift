//
//  LongPressButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-14.
//

import SwiftUI

struct PressedCardButton:View {
    @Binding var cardIsTappedScale:CGFloat
    @State var cardHasHadTap:Bool = false
    let action:() -> Void
    let maxDistanceToMove:CGFloat = 20
    var body: some View {
        content
    }
 
    var content:some View{
        ZStack{
            Image(systemName: "arrow.up.left.and.arrow.down.right")
            .foregroundStyle(Color.black.opacity(0.7))
            .font(.title3)
            .bold()
            .hLeading()
            .vBottom()
            .padding([.leading,.bottom],2.0)
        }
        .gesture(cardDragGesture)
        .frame(height: 30.0)
        .hLeading()
    }
}

//MARK: - GESTURE
extension PressedCardButton{
    var cardDragGesture: some Gesture {
        DragGesture(minimumDistance: 0.0,coordinateSpace: .global)
        .onChanged { value in
            let w = value.translation.width
            let h = value.translation.height
            if (-maxDistanceToMove < w && w < maxDistanceToMove) &&
                (-maxDistanceToMove < h && h < maxDistanceToMove){
                if !cardHasHadTap{
                    withAnimation{
                        cardIsTappedScale = 0.8
                    }
                    cardHasHadTap = true
                }
            }
            else{
                withAnimation{
                    cardIsTappedScale = 1.0
                }
            }
         }
        .onEnded { value in
            if cardIsTappedScale == 0.8{
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2){
                    action()
                }
            }
            cardHasHadTap = false
         }
    }
}
