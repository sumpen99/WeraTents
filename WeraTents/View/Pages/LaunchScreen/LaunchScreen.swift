//
//  LaunchScreen.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

struct LaunchScreen:View {
    @EnvironmentObject var appStateViewModel:AppStateViewModel
    @State var firstAnimation:Bool = false
    @State var secondAnimation:Bool = false
    @State var startFadeoutAnimation:Bool = false
    @State var labeltext = "©Weratents"
    
    @ViewBuilder
    var label:some View{
       Text(labeltext)
        .font(.largeTitle)
        .foregroundStyle(Color.white)
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
        GeometryReader{ reader in
            ZStack {
               background
               label
            }
            .onReceive(animationTimer) { timerValue in
                updateAnimation()
            }
            //.rotation3DEffect(.degrees(startFadeoutAnimation ? 180 : 0), axis:(x:1,y:1,z:1))
            .rotationEffect(.degrees(startFadeoutAnimation ? 360 : 0))
            .frame(width: startFadeoutAnimation ? 0 : reader.size.width,
                   height: startFadeoutAnimation ? 0 : reader.size.height)
            .opacity(startFadeoutAnimation ? 0 : 1)
            .vCenter()
            .hCenter()
        }
        
    }
    
    func updateAnimation() {
        switch appStateViewModel.launchState {
            case .START:
                withAnimation(.easeInOut(duration: 0.9)) {
                    firstAnimation.toggle()
                }
            case .CONTINUE:
                if secondAnimation == false {
                    withAnimation(.easeInOut(duration: 0.9)) {
                        self.secondAnimation = true
                        startFadeoutAnimation = true
                    }
                }
            case .FINISHED:
               break
            }
        }
}
