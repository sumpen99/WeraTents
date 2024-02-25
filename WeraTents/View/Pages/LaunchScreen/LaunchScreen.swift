//
//  LaunchScreen.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

struct LaunchScreen:View {
    @EnvironmentObject var launchScreenViewModel:LaunchScreenViewModel
    @State var firstAnimation:Bool = false
    @State var secondAnimation:Bool = false
    @State var startFadeoutAnimation:Bool = false
    @State var labeltext = "©Weratents"
    
    @ViewBuilder
    var image:some View{
        Image("weratent-logo")
        .rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800))
        .scaleEffect(secondAnimation ? 0 : 1)
        .offset(y: secondAnimation ? 400 : 0)
        .hCenter()
        .vCenter()
        
    }
    
    @ViewBuilder
    var label:some View{
        /*AnimatedColorText(text:"©Weratents",
                          font: .largeTitle,
                          foreground: Color.white)*/
        AnimatedTypingText(text: $labeltext,
                           animation: $firstAnimation,
                           font: .largeTitle,
                           foreground: Color.white)
        .vBottom()
    }
    
    @ViewBuilder
    var backgroundColor:some View{
        Color.darkGreen.ignoresSafeArea()
    }
    
    let animationTimer = Timer
            .publish(every: 0.5, on: .current, in: .common)
            .autoconnect()
    
    
    var body: some View {
        ZStack {
            backgroundColor
            image
            label
        }.onReceive(animationTimer) { timerValue in
            updateAnimation()
        }.opacity(startFadeoutAnimation ? 0 : 1)
    }
    
    func updateAnimation() {
            switch launchScreenViewModel.state {
            case .START:
                withAnimation(.easeInOut(duration: 0.9)) {
                    firstAnimation.toggle()
                }
            case .CONTINUE:
                if secondAnimation == false {
                    withAnimation(.linear) {
                        self.secondAnimation = true
                        startFadeoutAnimation = true
                    }
                }
            case .FINISHED:
               break
            }
        }
}
