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
    var label:some View{
        AnimatedTypingText(text: $labeltext,
                           animation: $firstAnimation,
                           font: .largeTitle,
                           foreground: Color.white)
        .vBottom()
    }
    
    @ViewBuilder
    var background:some View{
        Image("background")
        .resizable()
        .ignoresSafeArea()
    }
    
    let animationTimer = Timer
            .publish(every: 0.5, on: .current, in: .common)
            .autoconnect()
    
    
    var body: some View {
        ZStack {
            background
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
