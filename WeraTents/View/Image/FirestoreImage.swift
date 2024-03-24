//
//  FirestoreImage.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-20.
//

import SwiftUI

enum FirestoreImageType{
    case BASE
    case PICKER
    case RESIZABLE_ONLY
    case ZOOMABLE
}

struct FirestoreImage:View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    let iconImageUrl:String?
    var imageType:FirestoreImageType = .BASE
    var ignoreSpinner:Bool = false
    var frameHeight:CGFloat = 0.0
    @State var uIImage:UIImage?
    @State var scale:CGFloat = 1.0
    
    var body: some View {
        content
        .onChange(of: iconImageUrl,initial: true){ oldValue ,newValue in
            self.uIImage = nil
            if let newValue = newValue{
                if let url = fileExistsInsideCache(filename: newValue),
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data){
                    self.uIImage = uiImage
                }
                else{
                    firestoreViewModel.currentIconImage(newValue){ uiImage in
                        DispatchQueue.global(qos: .background).async {
                            ServiceManager.writeImageToCache(fileName: newValue, uiImage: uiImage){ _ in }
                        }
                        self.uIImage = uiImage
                     }
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
                switch imageType{
                case .BASE:
                    Image(uiImage: uIImage)
                    .resizable()
                    .scaledToFit()
                case .PICKER:
                    Image(uiImage: uIImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(1.0)
                    .background(Circle().fill(Color.white))
                case .RESIZABLE_ONLY:
                    Image(uiImage: uIImage)
                    .resizable()
                    .clipped()
                case .ZOOMABLE:
                    ZStack{
                        Image(uiImage: uIImage)
                        .resizable()
                        .scaleEffect(self.scale)
                        .gesture(magnification)
                        .clipped()
                        
                    }
                    .frame(height: frameHeight)
                }
            }
            else if !ignoreSpinner{
                SpinnerAnimation()
            }
        }
        
    }
}

//MARK: - GESTURE
extension FirestoreImage{
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                self.scale = value.magnitude
            }
            .onEnded { _ in
                self.scale = 1.0
            }
    }
    
}

//MARK: - FUNCTIONS
extension FirestoreImage{
    func fileExistsInsideCache(filename toSearchFor:String) -> URL?{
        return ServiceManager.fileExistInside(folder: .PNG,
                                              fileName: toSearchFor,
                                               ext: TempFolder.PNG.rawValue)
    }
}
