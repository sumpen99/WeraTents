//
//  FlashView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-16.
//

import SwiftUI

struct ScreenShotAnimation:View {
    @State private var flag = false
    @Binding var arAnimationState:[Bool]
    let uiImage:UIImage?
    
    var body: some View {
        if arAnimationState[ArAnimationState.FLASH_SCREEN.rawValue]{
            flashScreenContent
            .task{
                ServiceManager.playSystemSound(with: 1108)
            }
        }
        else if arAnimationState[ArAnimationState.SEND_CARD.rawValue]{
            flyingCardContent
            .padding()
        }
        
    }
    
}

//MARK: - SMOOTH ANIMATION
extension ScreenShotAnimation{
    var timeCurveAnimation: Animation {
        return Animation.timingCurve(0.5, 0.8, 0.8, 0.3, duration: 1.0)
    }
}

//MARK: - DELAYED DESTROY
extension ScreenShotAnimation{
    var delayedContent:some View{
        Color.clear
    }
}

//MARK: - FLASH SCREEN
extension ScreenShotAnimation{
     var flashScreenContent:some View{
         Color.white
        .ignoresSafeArea()
        .task{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
                withAnimation{
                    arAnimationState[ArAnimationState.FLASH_SCREEN.rawValue] = false
                }
            }
        }
    }
}
//MARK: - FLYING CARD
extension ScreenShotAnimation{
  
    var flyingCardContent: some View {
        flyingCard
        .onAppear {
            withAnimation(timeCurveAnimation) {
                self.flag.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                withAnimation{
                    arAnimationState[ArAnimationState.SEND_CARD.rawValue] = false
                    arAnimationState[ArAnimationState.SAVING_SCREEN_SHOT.rawValue] = false
                    arAnimationState[ArAnimationState.SHOW_TAKEN_PICTURE.rawValue] = true
                }
            }
        }
        
    }
    
    @ViewBuilder
    var flyingCard:some View{
        if let uiImage = uiImage{
            GeometryReader { reader in
                ZStack(alignment:.topLeading) {
                    Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                    .rotation3DEffect(.degrees(self.flag ? 360.0 : 0.0), 
                                      axis: (x:1.0,y:1.0,z:0.0))
                    .frame(width: self.flag ? 0 : 150.0,
                           height:self.flag ? 0 : 150.0)
                    .offset(x:self.flag ? 0 : -75 ,
                            y:self.flag ? 0 : -75)
                    .modifier(FollowPathModifier(pct: self.flag ? 1 : 0,
                                                 path: ShapeFlyingCard.createPath(
                                                    in:reader.boundingRect(),
                                                    shiftPath: false),
                                                    rotate: false))
                    
                }
             }
        }
        else{
            Color.clear
        }
    }
}
