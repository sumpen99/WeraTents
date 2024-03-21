//
//  SpinnerAnimation.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

enum AnimateSpinnerState:Int{
    case START_ANIMATE
    case SHOW_LONG_TIME_TEXT
    case BREAK
}

struct SpinnerTimer{
    let startTime:TimeInterval = Date().timeIntervalSinceReferenceDate
    var delayStartTime:Double = 2.0
    var longTimePassed:Double = 10.0
    var toLongTimePassed:Double = 20.0
}

struct SpinnerAnimation: View {
    @State var animate:[Bool] = Array.init(repeating: false,count: 3)
    var timer:SpinnerTimer = SpinnerTimer()
    var size:CGFloat = 60.0
    var text:String = "Väntar..."
    var textColor:Color = Color.black
    var foregroundStyle:Color = Color.lightGold
    let animationTimer = Timer
        .publish(every: 1.0, on: .current, in: .common)
        .autoconnect()
  
    var body: some View {
        ZStack{
            if !stateIsActive(.BREAK){
                animatedtContent
            }
            else{
                
            }
        }
        .onDisappear{
            closeTimer()
        }
    }
}

//MARK: - ANIMATED CONTENT
extension SpinnerAnimation{
    
    var animatedtContent:some View{
        ZStack{
            animatedText
            animatedCircles
        }
        .onReceive(animationTimer) { timerValue in
            updateAnimation(timerValue.timeIntervalSinceReferenceDate)
        }
        .frame(width: size,height: size)
        .hCenter()
        .vCenter()
        .foregroundStyle(foregroundStyle)
        .opacity(stateIsActive(.START_ANIMATE) ? 1.0 : 0.0)
    }
    
    @ViewBuilder
    var animatedText:some View{
        if stateIsActive(.SHOW_LONG_TIME_TEXT){
            Text(text).font(.caption).foregroundStyle(textColor)
            .transition(.opacity.combined(with: .scale))
            .lineLimit(1)
            /*AnimatedTypingText(text: text,
                               font: .caption,
                               foreground: textColor)*/
        }
    }
    
    var animatedCircles:some View{
        GeometryReader { reader in
            ForEach(0..<5) { index in
                Group {
                    Circle()
                        .frame(width: reader.size.width / 5, height: reader.size.height / 5)
                        .scaleEffect(calcScale(index: index))
                        .offset(y: calcYOffset(reader.size))
                }
                .frame(width: reader.size.width, height: reader.size.height)
                .rotationEffect(!stateIsActive(.START_ANIMATE) ? .degrees(0) : .degrees(360))
                .animation(Animation.timingCurve(0.5, 0.15 + Double(index) / 5,
                                                 0.25, 1,duration: 1.5)
                .repeatForever(autoreverses: false),value: stateIsActive(.START_ANIMATE))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

//MARK: - FUNCTIONS
extension SpinnerAnimation{
    func updateAnimation(_ timeInterval:TimeInterval){
        let secondsPassed = timeInterval - timer.startTime
        if secondsPassed > timer.toLongTimePassed{
            closeTimer()
            animateState(.BREAK)
        }
        if secondsPassed > timer.longTimePassed{
            animateState(.SHOW_LONG_TIME_TEXT)
        }
        if secondsPassed > timer.delayStartTime{ animateState(.START_ANIMATE) }
    }
    
    func animateState(_ state:AnimateSpinnerState){
        if animate[state.rawValue]{ return }
        withAnimation{
            animate[state.rawValue] = true
        }
    }
    
    func closeTimer(){
        animationTimer.upstream.connect().cancel()
    }
    
    func stateIsActive(_ state:AnimateSpinnerState) -> Bool{
        return animate[state.rawValue]
    }
    
    func calcScale(index: Int) -> CGFloat {
        return (!animate[AnimateSpinnerState.START_ANIMATE.rawValue] ? 1 - CGFloat(Float(index)) / 5 : 0.2 + CGFloat(index) / 5)
    }
    
    func calcYOffset(_ size: CGSize) -> CGFloat {
        return size.width / 10 - size.height / 2
    }
}
