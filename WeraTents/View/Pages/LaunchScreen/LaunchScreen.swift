//
//  LaunchScreen.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-25.
//

import SwiftUI

enum Animate:Int{
    case FIRST
    case SECOND
    case THIRD
    case FADE_OUT
    case ALL
}

struct LaunchScreen:View {
    @EnvironmentObject var appStateViewModel:AppStateViewModel
    @State var animate:[Bool] = Array.init(repeating: false,count: Animate.ALL.rawValue)
   
    @ViewBuilder
    var label:some View{
       Text("©Weratents")
            .font(animate[Animate.SECOND.rawValue] ? .title2 :
                  animate[Animate.THIRD.rawValue] ? .headline :
                  .largeTitle)
        .foregroundStyle(Color.white)
        .opacity(animate[Animate.THIRD.rawValue] ? 0.7 : 1)
        .rotation3DEffect(.degrees(animate[Animate.SECOND.rawValue] ? 45.0 : 0),
                          axis: (x:1.0,y:0.0,z:0.0))
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
        GeometryReader{ reader in
            ZStack {
               background
               label
            }
            .onReceive(animationTimer) { timerValue in
                updateAnimation()
            }
            .frame(width: !animate[Animate.THIRD.rawValue] ? reader.size.width :
                    !animate[Animate.FADE_OUT.rawValue] ? reader.min()/1.5 : 0 ,
                   height: !animate[Animate.SECOND.rawValue] ? reader.size.height : 
                    !animate[Animate.FADE_OUT.rawValue] ? reader.min()/1.5 : 0 )
           .opacity(animate[Animate.FADE_OUT.rawValue] ? 0 : 1)
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
           default:
               break
            }
        }
}
