//
//  FirestoreViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class FirestoreRepository{
    private let firestoreDB = Firestore.firestore()
    private let firestoreStorage = Storage.storage()
    
    func shutDown(){
        firestoreDB.terminate()
    }
}

class FirestoreViewModel:ObservableObject{
    @Published var tents:[TentItem] = []
    //let repo = FirestoreRepository()
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
