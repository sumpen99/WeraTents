//
//  DropShadowButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-11.
//

import SwiftUI

struct DropShadowButton:View {
    let buttonText:String
    let frameWidth:CGFloat
    let action:() -> Void
    //@State private var scaleAmount = 1.0
    var body: some View {
        Button(action: action, label: {
            content
        })
        /*.onAppear{
            withAnimation{
                scaleAmount = 1.025
            }
        }*/
    }
    
    var content:some View{
        ZStack{
            Color.lightGold
            Text(buttonText)
            //.scaleEffect(scaleAmount)
            .foregroundStyle(Color.white)
            .bold()
            .shadow(color: Color.materialDarkest, radius: 5, x: 0, y: 5)
        }
        .frame(width: frameWidth)
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_BRAND))
        .shadow(color:Color.lightGold,radius: CORNER_RADIUS_BRAND)
        .padding()
        //.scaleEffect(scaleAmount)
        //.animation(.linear(duration: 0.55).delay(0.2).repeatForever(autoreverses: true),value: scaleAmount)
        //.animation(.linear(duration: 0.1).delay(0.2).repeatForever(autoreverses: true),value: animationAmount)
        //.animation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true), value: animate)
        //.animation(.bouncy(duration: 0.5).repeatForever(autoreverses: true), value: animate)
    }
}
