//
//  ToggleSectionButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

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

struct ToggleSectionButtonHeavy<Header:View>: View {
  let header: Header
  @Binding var isOn: Bool
  let onLabel: String
  let offLabel: String
  
  var body: some View {
    Button(action: {
      withAnimation {
        isOn.toggle()
      }
    }, label: {
        Text(isOn ? onLabel : offLabel).font(.body)
    })
    .foregroundColor(Color.darkGreen)
    .hTrailing()
    .overlay(
        header
        .hLeading()
    )
  }
}
