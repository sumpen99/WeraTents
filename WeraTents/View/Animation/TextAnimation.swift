//
//  TextAnimation.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

struct AnimatedColorText:View {
    let text:String
    let font:Font
    let foreground:Color
    @State var animation:Bool = false
    
    var baseText:some View{
        HStack(spacing:0){
            ForEach(0..<text.count,id:\.self){ index in
                Text(String(text[text.index(text.startIndex,offsetBy: index)]))
                    //.font(.system(size: 75.0,weight: .bold))
                    .font(font)
                    .foregroundStyle(foreground)
          }
        }
     }
    
    var randomDigitColor:some View{
        HStack(spacing:0){
            ForEach(0..<text.count,id:\.self){ index in
                Text(String(text[text.index(text.startIndex,offsetBy: index)]))
                    //.font(.system(size: 75.0,weight: .bold))
                    .font(font)
                    .foregroundStyle(Color.random())
            }
        }
        .mask{
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5),Color.white,Color.white.opacity(0.5)]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                
                )
                .rotationEffect(.init(degrees: 70))
                .padding(20)
                .offset(x:-200)
                .offset(x:animation ? 500 : 0)
            
        }
        .onAppear{
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)){
                animation.toggle()
            }
        }
        .zIndex(1)
    }
    
    var body:some View{
        ZStack{
            baseText
            randomDigitColor
        }
    }
}

struct AnimatedTypingText:View {
    let text:String
    let font:Font
    let foreground:Color
    @State var animatedText:String = ""
 
    var body: some View {
        Text(animatedText)
        //.animation(.interpolatingSpring(stiffness: 350, damping: 90, initialVelocity: 10))
        .animation(.easeInOut(duration: 0.15))
        .font(font)
        .bold()
        .foregroundStyle(foreground)
        .onAppear{
            animateText()
        }
    }

        func animateText() {
            for (index, character) in text.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.26) {
                    animatedText.append(character)
                     //UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    if index == text.count-1{
                        withAnimation{
                            animatedText = ""
                            animateText()
                        }
                    }
                }
            }
    
        }
}
