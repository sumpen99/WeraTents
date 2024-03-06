//
//  Zoomable.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-06.
//

import SwiftUI

struct ZoomableImage:View {
    @GestureState private var zoom = 1.0
    let uiImage:UIImage?
    let size:CGFloat
    
    var body: some View {
        if let uiImage = uiImage{
            ZStack{
                Image(uiImage: uiImage)
                .resizable()
                .scaleEffect(zoom)
                .clipped()
                .gesture(
                    MagnifyGesture()
                        .updating($zoom) { value, gestureState, transaction in
                            gestureState = value.magnification
                        }
                )
            }
            .frame(height: size)
        }
    }
}
