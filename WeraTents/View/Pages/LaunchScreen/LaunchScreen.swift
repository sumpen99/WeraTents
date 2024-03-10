//
//  LaunchScreen.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

enum AnimateLaunchState:Int{
    case FIRST
    case SECOND
    case THIRD
    case FADE_OUT
    case ALL
}

struct LaunchScreen:View {
    @EnvironmentObject var appStateViewModel:AppStateViewModel
    @State var animate:[Bool] = Array.init(repeating: false,count: AnimateLaunchState.ALL.rawValue)
   
    @ViewBuilder
    var label:some View{
       Text("©Weratents")
        .font(stateIsActive(.SECOND) ? .title2 :
              stateIsActive(.THIRD) ? .headline :
              .largeTitle)
        .foregroundStyle(Color.white)
        //.animation(.linear(duration: 0.25),value: animate[Animate.FIRST.rawValue])
        .opacity(stateIsActive(.FIRST) ? 0 : 1)
        /*.rotation3DEffect(.degrees(animate[Animate.SECOND.rawValue] ? 45.0 : 0),
                          axis: (x:1.0,y:0.0,z:0.0))*/
        .vBottom()
        .hCenter()
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
        animatedContent
        .onDisappear{
            animationTimer.upstream.connect().cancel()
        }
        
    }
    
    var animatedContent:some View{
        GeometryReader{ reader in
            ZStack {
               background
               label
            }
            .onReceive(animationTimer) { timerValue in
                updateAnimation()
            }
            .frame(width: !stateIsActive(.THIRD) ? reader.size.width :
                    !stateIsActive(.FADE_OUT) ? reader.min()/1.5 : 0 ,
                   height: !stateIsActive(.SECOND) ? reader.size.height :
                    !stateIsActive(.FADE_OUT) ? reader.min()/1.5 : 0 )
           .opacity(stateIsActive(.FADE_OUT) ? 0 : 1)
            .vCenter()
            .hCenter()
        }
    }
    
    func updateAnimation() {
        switch appStateViewModel.launchState {
            case .CONTINUE:
                if let index = animate.firstIndex(where: {!$0}){
                    withAnimation(.easeInOut(duration: 0.5)) {
                        animate[index] = true
                    }
                }
            default: break
        }
    }
    
    func stateIsActive(_ state:AnimateLaunchState) -> Bool{
        return animate[state.rawValue]
    }
}
