//
//  BaseButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-08.
//

import SwiftUI

struct ExpandableButton:View {
    @Binding var buttonSelection:ButtonSelection?
    let label:ButtonSelection
    let width:CGFloat
    let baseHeight:CGFloat = 45.0
    let action:() -> Void
    
    var isToggled:Bool{
        label == buttonSelection
    }
    
    var body: some View {
        Button(action: action, label: {
            if isToggled{
                content
                .bold()
            }
            else{
                content
                .padding()
            }
        })
        .frame(width:width,height: isToggled ? baseHeight * 1.25 : baseHeight)
        .background{Color.lightGreen}
        .clipShape(RoundedRectangle(cornerRadius: 5.0))
    }
    
    var content:some View{
        Text(label.rawValue)
        .font(.body)
        .foregroundStyle(Color.white)
        .opacity(isToggled ? 1.0 : 0.5)
    }
      
}
