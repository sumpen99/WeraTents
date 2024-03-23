//
//  CheckboxStyle.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-22.
//

import SwiftUI
struct CheckboxStyle: ToggleStyle {
    let alignLabelLeft:Bool
    let labelColor:Color
    let checkBoxColor:Color
    @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> some View {
        if alignLabelLeft{
            HStack{
                configuration.label
                .font(.headline)
                .bold()
                .foregroundStyle(labelColor)
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(checkBoxColor)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        withAnimation{
                            configuration.isOn.toggle()
                        }
                    }
            }
        }
        else{
            HStack{
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(checkBoxColor)
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .onTapGesture {
                        withAnimation{
                            configuration.isOn.toggle()
                        }
                    }
                configuration.label
                .font(.headline)
                .bold()
                .foregroundStyle(labelColor)
            }
        }
    }
}
