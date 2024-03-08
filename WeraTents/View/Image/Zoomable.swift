//
//  Zoomable.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-06.
//

import SwiftUI

struct ZoomableImage:View {
    @State var scale:CGFloat = 1.0
    let uiImage:UIImage?
    let size:CGFloat
    
    var magnification: some Gesture {
        MagnificationGesture()
            /*.updating($zoom) { value, gestureState, transaction in gestureState = value.magnification}*/
            //.onChanged { scale = $0 }
            .onChanged { value in
                self.scale = value.magnitude
            }
            .onEnded { _ in
                self.scale = 1.0
            }
    }
    
    var body: some View {
        if let uiImage = uiImage{
            ZStack{
                Image(uiImage: uiImage)
                .resizable()
                .scaleEffect(self.scale)
                .gesture(magnification)
                .clipped()
                
            }
            .frame(height: size)
        }
    }
}
