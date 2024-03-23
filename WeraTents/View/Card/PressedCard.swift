//
//  PressedCard.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-18.
//

import SwiftUI

struct PressedCard:View {
    let image:Image
    let labelText:String
    let descriptionText:String
    let scaleFactor:CGFloat
    let height:CGFloat
    let imageLabel:String
    let action:() -> Void
    @State var cardIsTappedScale:CGFloat = 1.0
    
    var body: some View {
        content
    }
    
    var content:some View{
        ZStack {
            Color.lightBrown
            HStack(spacing:0){
                VStack(spacing:0){
                    cardText
                    PressedCardButton(cardIsTappedScale: $cardIsTappedScale,
                                      scaleFactor: scaleFactor,
                                      imageLabel: imageLabel,
                                      action: action)
                }
                .hCenter()
                .padding(.top)
                image
                .resizable()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
        .frame(height: height)
        .hCenter()
        .shadow(color:Color.lightGold,radius: 2.0)
        .scaleEffect(cardIsTappedScale)
     }
    
    var cardText: some View{
        VStack(spacing: V_SPACING_REG){
            Text(labelText)
            .font(.caption)
            .foregroundStyle(Color.materialDark)
            .bold()
            Text(descriptionText).font(.caption2)
            .italic()
            .foregroundStyle(Color.materialDark)
       }
        .vTop()
        .padding(.horizontal)
        .hCenter()
    }
}
