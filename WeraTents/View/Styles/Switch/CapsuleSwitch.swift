//
//  CapsuleSwitch.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-24.
//

import SwiftUI

struct CapsuleSwitch:View {
    let namespace:Namespace.ID
    let namespaceName:String
    let labelLeft:String
    let labelRight:String
    @Binding var selectedLabel:String
    var body: some View {
        toggleGridButtons
    }
}

//MARK: - CONTENT
extension CapsuleSwitch{
    var toggleGridButtons:some View{
        HStack{
            gridHeaderCell(labelLeft)
            gridHeaderCell(labelRight)
        }
        .background{
            Color.materialDark
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
   }
    
    func gridHeaderCell(_ header:String) -> some View{
        return Text(header)
        .font(.headline)
        .bold()
        .frame(height: 33)
        .foregroundStyle(header == selectedLabel ? Color.background : Color.materialDarkest )
        .padding([.vertical],5)
        .padding([.horizontal],10)
        .background(
             ZStack{
                 if header == selectedLabel{
                     RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL)
                    .fill(Color.white)
                    .matchedGeometryEffect(id: namespaceName, in: namespace)
                 }
             }
        )
       .onTapGesture {
            withAnimation{
                selectedLabel = header
            }
        }
    }
}
