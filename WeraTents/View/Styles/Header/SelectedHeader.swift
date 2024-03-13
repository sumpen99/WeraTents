//
//  SelectedHeader.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

struct SelectedHeader:View {
    let namespace:Namespace.ID
    let label:String
    let thickness:CGFloat
    @Binding var bindingLabel:String?
    @State var scaleAmount:CGFloat = 1.0
    
    var body: some View {
        content
        .onChange(of: bindingLabel,initial: true){ oldValue,newValue in
            withAnimation{
                scaleAmount = newValue == label ? 1.25 : 1.0
            }
        }
    }
    
    var content:some View{
        Text(label)
        .scaleEffect(scaleAmount)
        .font(.headline)
        .bold()
        .frame(height: 33)
        .foregroundStyle(label == bindingLabel ? Color.white : Color.gray )
        .padding([.vertical],5)
        .padding([.horizontal],10)
        .background(
             ZStack{
                 if label == bindingLabel{
                     SplitLine(direction: .HORIZONTAL,color: Color.white,thickness: thickness)
                     .padding(.top)
                     .offset(y:10.0)
                     .matchedGeometryEffect(id: "CURRENT_SELECTED_HEADER", in: namespace)
                     .shadow(color:Color.white,radius: CORNER_RADIUS_BRAND)
                 }
             }
        )
        .onTapGesture {
            withAnimation{
                bindingLabel = label
            }
        }
    }
}
