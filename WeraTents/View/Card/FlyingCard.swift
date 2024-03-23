//
//  FlyingCard.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-21.
//

import SwiftUI

struct FlyingCardValues{
    let selectedImageUrl:String
    let startPosition:CGPoint
    let startValues:CGSize
    let endValues:CGSize
}

struct FlyingCard:View {
    @State var flag:Bool = false
    @Binding var animationState:[Bool]
    let flyingCardValues:FlyingCardValues
    
    var body: some View {
        flyingCardContent
    }
    
}

//MARK: - CONTENT
extension FlyingCard{
    var flyingCardContent: some View {
        flyingCard
        .onAppear {
            withAnimation(timeCurveAnimation) {
                flag.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                withAnimation{
                    animationState[ArAnimationState.SEND_PICKED_IMAGE.rawValue] = false
                    animationState[ArAnimationState.SHOW_SELECTED_TENT_IMAGE.rawValue] = true
                    animationState[ArAnimationState.SHOW_CAROUSEL.rawValue] = false
                }
            }
        }
        
    }
    
    var flyingCard:some View{
        GeometryReader { reader in
            ZStack(alignment:.topLeading) {
                FirestoreImage(iconImageUrl: flyingCardValues.selectedImageUrl,
                               imageType: .PICKER,
                               ignoreSpinner: true)
                .rotation3DEffect(.degrees(flag ? 360.0 : 0.0),
                                  axis: (x:1.0,y:1.0,z:0.0))
                .frame(width: self.flag ?
                        flyingCardValues.endValues.width :
                        flyingCardValues.startValues.width,
                       height:self.flag ? 
                       flyingCardValues.endValues.height :
                       flyingCardValues.startValues.height)
                .offset(x:self.flag ?
                        -flyingCardValues.endValues.width/2.0 :
                        -flyingCardValues.startValues.width/2.0,
                        y:self.flag ?
                        -flyingCardValues.endValues.height/2.0 :
                        -flyingCardValues.startValues.height/2.0)
                .modifier(FollowPathModifier(pct: flag ? 1 : 0,
                                             path: ShapeFlyingCard.createUpperPath(
                                                in:reader.boundingRect(),
                                                fromPoint: flyingCardValues.startPosition),
                                                rotate: false))
                
            }
         }
    }
}

//MARK: - SMOOTH ANIMATION
extension FlyingCard{
    var timeCurveAnimation: Animation {
        return Animation.timingCurve(0.5, 0.8, 0.8, 0.3, duration: 1.0)
    }
}
