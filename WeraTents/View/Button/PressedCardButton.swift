//
//  LongPressButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-14.
//

import SwiftUI

struct PressedCardButton:View {
    @Binding var cardIsTappedScale:CGFloat
    let scaleFactor:CGFloat
    let imageLabel:String
    let action:() -> Void
    @State var cardHasHadTap:Bool = false
    let maxDistanceToMove:CGFloat = 20
    var body: some View {
        content
    }
 
    var content:some View{
        ZStack{
            Image(systemName: imageLabel)
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
                    animateScaleFactorWith(value:scaleFactor)
                    cardHasHadTap = true
                }
            }
            else{
                animateScaleFactorWith(value:1.0)
            }
         }
        .onEnded { value in
            if cardIsTappedScale == scaleFactor{
                animateScaleFactorWith(value:1.0)
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.3){
                    action()
                }
            }
            cardHasHadTap = false
         }
    }
    
    func animateScaleFactorWith(value toAnimate:CGFloat){
        withAnimation{
            cardIsTappedScale = toAnimate
        }
    }
}
