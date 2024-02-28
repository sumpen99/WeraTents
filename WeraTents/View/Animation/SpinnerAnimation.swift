//
//  SpinnerAnimation.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

struct SpinnerAnimation: View {
    
    @State private var isAnimating: Bool = false
    
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
                .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                .animation(Animation.timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1,
                                                 duration: 1.5)
                    .repeatForever(autoreverses: false),value: isAnimating)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
   
    var body: some View {
        animatedCircles
        .onAppear {
            self.isAnimating = true
        }
    }
    
    func calcScale(index: Int) -> CGFloat {
        return (!isAnimating ? 1 - CGFloat(Float(index)) / 5 : 0.2 + CGFloat(index) / 5)
    }
    
    func calcYOffset(_ size: CGSize) -> CGFloat {
        return size.width / 10 - size.height / 2
    }
    
}
