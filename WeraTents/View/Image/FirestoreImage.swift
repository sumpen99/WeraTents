//
//  FirestoreImage.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-20.
//

import SwiftUI

struct FirestoreImage:View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    let iconImageUrl:String?
    @State var uIImage:UIImage?
    
    var body: some View {
        content
        .onChange(of: iconImageUrl,initial: true){ oldValue ,newValue in
            if let newValue = newValue{
                firestoreViewModel.currentIconImage(newValue){ uiImage in
                    self.uIImage = uiImage
                }
            }
            
        }
     }
    
    @ViewBuilder
    var content:some View{
        ZStack{
            if let uIImage = uIImage{
                Image(uiImage: uIImage)
                .resizable()
                .scaledToFit()
                .vTop()
            }
            else{
                SpinnerAnimation()
            }
        }
        
    }
}
