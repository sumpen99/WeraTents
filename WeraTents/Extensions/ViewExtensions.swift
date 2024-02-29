//
//  ViewExtension.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

extension View{
    func hFill() -> some View{
        self.frame(minWidth: 0, maxWidth: .infinity)
    }
    
    func hLeading() -> some View{
        self.frame(maxWidth: .infinity,alignment: .leading)
    }
    
    func hTrailing() -> some View{
        self.frame(maxWidth: .infinity,alignment: .trailing)
    }
    
    func hCenter() -> some View{
        self.frame(maxWidth: .infinity,alignment: .center)
    }
    
    func vTop() -> some View{
        self.frame(maxHeight: .infinity,alignment: .top)
    }
    
    func vBottom() -> some View{
        self.frame(maxHeight: .infinity,alignment: .bottom)
    }
    
    func vCenter() -> some View{
        self.frame(maxHeight: .infinity,alignment: .center)
    }
    
    func toast(isShowing: Binding<Bool>) -> some View {
        self.modifier(Toast(isShowing: isShowing))
    }
    
    func badge(count: Binding<Int>) -> some View {
        self.modifier(Badge(count: count))
    }
    
    func checkmarkCircle() -> some View{
        Image(systemName: "checkmark.circle.fill")
        .resizable()
        .background{
            Circle().fill(Color.black).frame(width: 26, height: 26)
        }
        .foregroundStyle(Color.white)
        .frame(width: 24, height: 24)
        .font(.system(size: 20, weight: .bold, design: .default))
        .hLeading()
        .vBottom()
        .padding([.leading,.bottom])
    }
}


func roundedImage(_ name:String,
                  font:Font,
                  scale:Image.Scale,
                  radius:CGFloat,
                  foreground:Color=Color.black,
                  background:Color=Color.white) -> some View{
        Image(systemName: name)
        .font(font)
        .bold()
        .foregroundStyle(foreground)
        .imageScale(scale)
        .padding()
        .background(background)
        .frame(width: radius,height:radius)
        .clipShape(Circle())
}

func buttonImage(_ name:String,
                  font:Font,
                  foreground:Color) -> some View{
    Image(systemName: name)
    .font(font)
    .bold()
    .foregroundStyle(foreground)
   
}

