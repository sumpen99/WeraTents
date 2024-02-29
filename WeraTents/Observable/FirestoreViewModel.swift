//
//  FirestoreViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//

import SwiftUI



class FirestoreViewModel:ObservableObject{
    @Published var tents:[TentItem] = []
    
}

//MARK: - CONNECTION
extension FirestoreViewModel{
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

//MARK: - HELPER
extension FirestoreViewModel{
    var hasTents:Bool{
        tents.count > 0
    }
}
