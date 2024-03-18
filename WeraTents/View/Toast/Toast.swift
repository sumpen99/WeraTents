//
//  Toast.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

enum ToastState{
    case BASE
    case SUCCESS
    case FAIL
}

struct ToastConfiguration {
    static var message:String = ""
    static var textColor:Color = Color.white
    static var font:Font = .system(size: 14)
    static var backgroundColor:Color = Color.white
    static var duration:TimeInterval = Toast.short
    static var transition:AnyTransition = .opacity
    static var animation:Animation = .linear(duration: 0.3)
    
    static func config(state:ToastState,message:String,duration:TimeInterval = Toast.short){
        switch state{
        case .BASE:
            self.textColor = Color.materialDarkest
        case .SUCCESS:
            self.textColor = Color.materialDarkest
        case .FAIL:
            self.textColor = Color.red
        }
        self.message = message
        self.duration = duration
    }
    
}

struct Toast: ViewModifier {
    static let short: TimeInterval = 2
    static let long: TimeInterval = 3.5
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
        .vCenter()
        .hCenter()
     }
     
    var toastView: some View {
        ZStack {
             if isShowing {
                Group {
                    Text(ToastConfiguration.message)
                        .multilineTextAlignment(.center)
                        .foregroundColor(ToastConfiguration.textColor)
                        .font(ToastConfiguration.font)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 30)
                }
                .background(Capsule().foregroundColor(ToastConfiguration.backgroundColor))
                .cornerRadius(8)
           }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .animation(ToastConfiguration.animation, value: isShowing)
        .transition(ToastConfiguration.transition)
    }
}

 

  
