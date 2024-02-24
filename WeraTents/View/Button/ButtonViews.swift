//
//  ButtonViews.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

//MARK: - CUSTOM BACKBUTTON
struct BackButton:View{
    @Environment(\.dismiss) private var dismiss
    var imgLabel:String = "chevron.left"
    var color:Color = Color.black
    var action: (() -> Void)? = nil
    
    var body: some View{
        Button(action:backAction){ label }
    }
    
    var label:some View{
        Image(systemName: imgLabel)
        .font(.largeTitle)
        .imageScale(.medium)
        .bold()
        .foregroundStyle(color)
    }
    
    func backAction(){
        action?()
        dismiss()
    }
}

//MARK: - CUSTOM COLLAPSABLE LIST BUTTON
struct ToggleSectionButton: View {
  let title: String
  @Binding var isOn: Bool
  let onLabel: String
  let offLabel: String
  
  var body: some View {
    Button(action: {
      withAnimation {
        isOn.toggle()
      }
    }, label: {
      if isOn {
        Text(onLabel)
      } else {
        Text(offLabel)
      }
    })
    .font(.caption)
    .foregroundColor(Color.darkGreen)
    .hTrailing()
    .overlay(
        Text(title)
        .hLeading()
    )
  }
}
