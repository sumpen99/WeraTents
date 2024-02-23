//
//  FirestoreViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//

import SwiftUI

struct TentItem:CarouselItem{
    var id:Int
    var identifier: String
    var title:String
    var img:Image
    
    
}

class FirestoreViewModel:ObservableObject{
    @Published var tents:[TentItem] = []
    
    func loadImageAssets(){
        let imageNames = ServiceManager.readAssetsFromBundle("Tent.bundle")
        ServiceManager.loadImagesFromBundle("Tent", imageNames: imageNames){ [weak self ] (opResult,tentItems) in
           if let strongSelf = self,
               let tentItems = tentItems{
                strongSelf.tents = tentItems
            }
        }
    }
}
