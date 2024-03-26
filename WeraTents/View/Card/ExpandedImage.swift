//
//  File.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-26.
//

import SwiftUI

struct ExpandedImageValues:Equatable{
    let selectedImage:Image?
    let startPosition:CGPoint
    let startValues:CGSize
    let endValues:CGSize
}

struct ExpandedImage:View {
    @Binding var expandedImageValues:ExpandedImageValues?
    @State var flag:Bool = false
    
    var body: some View {
        expandedImageContent
        .animation(.easeInOut(duration: 0.5), value: flag)
        .onAppear {
            withAnimation{
                flag.toggle()
            }
        }
        .onTapGesture {
            withAnimation{
                flag.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                    expandedImageValues = nil
                }
            }
        }
    }
    
}

//MARK: - CONTENT
extension ExpandedImage{
    
    @ViewBuilder
    var expandedImageContent:some View{
        if let expandedImageValues = expandedImageValues{
            GeometryReader { reader in
                ZStack(alignment:.topLeading) {
                    expandedImageValues.selectedImage?
                    .resizable()
                    .clipped()
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL)
                        .fill(Color.white)
                }
                .padding(2)
                .frame(width: self.flag ?
                       reader.size.width :
                        50.0,
                       height:self.flag ?
                       reader.size.height :
                        50.0)
                .offset(x:self.flag ?
                        -reader.size.width/2.0 :
                            -25.0,
                        y:self.flag ?
                        -reader.size.height/2.0 :
                            -25.0)
                .modifier(FollowPathModifier(pct: flag ? 1 : 0,
                                             path: ShapeFlyingCard.createCenerPath(
                                                in:reader.boundingRect(),
                                                fromPoint: expandedImageValues.startPosition),
                                                rotate: false))
                
            }
        }
        
    }
}
