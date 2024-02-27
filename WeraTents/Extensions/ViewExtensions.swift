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
     
    func customBackButton(imgLabel:String="chevron.left",
                          color:Color = Color.black,
                          action: (() -> Void)? = nil) -> some View{
        self.safeAreaInset(edge: .top){
            BackButton(imgLabel: imgLabel,color:color,action:action)
            .padding()
        }
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

func roundedImage(_ img:Image,
                  font:Font,
                  scale:Image.Scale,
                  radius:CGFloat,
                  foreground:Color=Color.black,
                  background:Color=Color.white) -> some View{
        img
        .font(font)
        .bold()
        .foregroundStyle(foreground)
        .imageScale(scale)
        .padding()
        .background(background)
        .frame(width: radius,height:radius)
        .clipShape(Circle())
}
