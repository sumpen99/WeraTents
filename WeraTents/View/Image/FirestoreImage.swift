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
    var isPicker:Bool = false
    var ignoreSpinner:Bool = false
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
     
}

//MARK: - CONTENT
extension FirestoreImage{
    @ViewBuilder
    var content:some View{
        ZStack{
            if let uIImage = uIImage{
                if isPicker{
                    Image(uiImage: uIImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(5.0)
                    .background(Circle().fill(Color.materialDark))
                }
                else{
                    Image(uiImage: uIImage)
                    .resizable()
                    .scaledToFit()
                }
            }
            else if !ignoreSpinner{
                SpinnerAnimation()
            }
        }
        
    }
}
