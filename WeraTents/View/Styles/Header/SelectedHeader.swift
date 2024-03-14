//
//  SelectedHeader.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-13.
//

import SwiftUI

enum SelectedAnimation{
    case UNDERLINE
    case CAPSULE
    case RECTANGLE
    case NONE
}

struct SelectedHeader:View {
    let namespace:Namespace.ID
    let namespaceName:String
    let label:String
    let thickness:CGFloat
    @Binding var bindingLabel:String?
    var selectedAnimation:SelectedAnimation = .UNDERLINE
    @State var scaleAmount:CGFloat = 1.0
    
    
    var body: some View {
        content
        .onTapGesture {
            withAnimation{
                bindingLabel = label
            }
        }
        
    }
    
    var content:some View{
        ZStack{
            switch selectedAnimation {
            case .UNDERLINE:
                underlineAnimation
            case .CAPSULE:
                capsuleAnimation
            case .RECTANGLE:
                rectangleAnimation
            case .NONE:
                contentlabel
            }
        }
    }
    
}

//MARK: - BASE TEXT
extension SelectedHeader{
    var contentlabel:some View{
        Text(label)
            .scaleEffect(scaleAmount)
            .font(.headline)
            .bold()
            .frame(height: 33)
            .foregroundStyle(label == bindingLabel ? Color.white : Color.gray )
            .padding([.vertical],5)
            .padding([.horizontal],10)
            .onChange(of: bindingLabel,initial: true){ oldValue,newValue in
                withAnimation{
                    scaleAmount = newValue == label ? 1.25 : 1.0
                }
            }
    }
}

//MARK: - ANIMATION RECTANGLE
extension SelectedHeader{
    var rectangleAnimation:some View{
        contentlabel
        .padding(.horizontal,5)
        .background(
            ZStack{
                if label == bindingLabel{
                    ZStack{
                        Color.lightGold
                    }
                    .matchedGeometryEffect(id: namespaceName, in: namespace)
                    .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_BRAND))
                    .shadow(color:Color.lightGold,radius: CORNER_RADIUS_BRAND)
                 }
            }
            
       )
        
    }
}

//MARK: - ANIMATION CAPSULE
extension SelectedHeader{
    var capsuleAnimation:some View{
        contentlabel
        .padding(.horizontal,5)
        .background(
             ZStack{
                 if label == bindingLabel{
                     Capsule()
                     .stroke(lineWidth: thickness)
                     .foregroundStyle(Color.white)
                     .matchedGeometryEffect(id: namespaceName, in: namespace)
                 }
             }
        )
        
    }
}

//MARK: - ANIMATION UNDERLINE
extension SelectedHeader{
    var underlineAnimation:some View{
        contentlabel
        .background(
             ZStack{
                 if label == bindingLabel{
                     SplitLine(direction: .HORIZONTAL,color: Color.white,thickness: thickness)
                     .padding(.top)
                     .offset(y:10.0)
                     .matchedGeometryEffect(id: namespaceName, in: namespace)
                     .shadow(color:Color.white,radius: CORNER_RADIUS_BRAND)
                 }
             }
        )
    }
}
