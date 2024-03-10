//
//  FirestoreViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

enum DbPath:String{
    case WERA_TENTS = "Wera_Tents"
    case TENT_ICONS = "Icons"
    case TENT_MODELS = "Models"
}

//MARK: - FIRESTORE REPOSITORY
class FirestoreRepository{
    private let dB = Firestore.firestore()
    private let storage = Storage.storage()
    
    func shutDown(){
        dB.terminate()
    }
    
    func tentCollection() -> CollectionReference{
        let collection = DbPath.WERA_TENTS.rawValue
        return dB.collection(collection)
    }
    
    func tentDocument(tentId:String) -> DocumentReference{
        let base = DbPath.WERA_TENTS.rawValue
        return dB.collection(base).document(tentId)
    }
     
    func tentIconReference(tentId:String) -> StorageReference{
        let folder = DbPath.TENT_ICONS.rawValue
        let path = "\(folder)/\(tentId).png"
        return storage.reference().child(path)
    }
    
    func tentModelReference(tentId:String) -> StorageReference{
        let folder = DbPath.TENT_MODELS.rawValue
        let path = "\(folder)/\(tentId).usdz"
        return storage.reference().child(path)
    }
}

//MARK: - FIRESTORE VIEWMODEL
class FirestoreViewModel:ObservableObject{
    @Published var tentAssets:[TentItem] = []
    @Published var isLoadingData:Bool = false
    let repo = FirestoreRepository()
}

//MARK: - FIRESTORE VIEWMODEL LOAD DATA
extension FirestoreViewModel{
    
    func loadTentAssets(){
       if FETCH_LOCALLY{ loadTentAssetsFromLocal() }
        else{ loadTentAssetsFromServer() }
    }
    
    func loadTentModelData(_ fileName:String,completion: @escaping (URL?) -> Void){
        if  FETCH_LOCALLY{
            DispatchQueue.global(qos: .background).async {
                let url = ServiceManager.localUSDZUrl(fileName: fileName)
                DispatchQueue.main.async { completion(url) }
            }
        }
        else{
            downloadTentModelFromStorage(tentId: fileName){ (error,data) in
                if let data = data{
                    ServiceManager.writeDataToTemporary(data, fileName: fileName, ext: "usdz"){ url in
                        DispatchQueue.main.async { completion(url) }
                    }
                }
                else{
                    debugLog(object: error?.localizedDescription ?? "Unexpected error")
                    completion(nil)
                }
            }
        }
    }
    
    private func loadTentAssetsFromLocal(){
        ServiceManager.readJsonFromBundleFile("data.json",value: TentDb.self){ [weak self] data in
            if let strongSelf = self,
               let data = data{
                for tent in data{
                    ServiceManager.loadImagesFromBundle("Tent",
                                                       imageNames: [tent.iconStorageIds?[0] ?? ""]){ uiImages in
                        if let uiImage = uiImages.first{
                            let count = strongSelf.tentAssets.count
                            strongSelf.tentAssets.append(tent.toTentItem(index: count, image: Image(uiImage: uiImage)))
                        }
                     }
                }
            }
        }
    }
     
    private func loadTentAssetsFromServer(){
        let coll = repo.tentCollection()
        coll.getDocuments(){ [weak self] snapshot,error in
            guard let strongSelf = self,
                  let snapshot = snapshot else { return }
            for doc in snapshot.documents{
                guard let tent = try? doc.data(as : TentDb.self),
                      let iconUrl = tent.iconStorageIds?[0]
                else{ continue }
                strongSelf.downloadTentIconImageFromStorage(tentId: iconUrl){ error,uiImage in
                    if let uiImage = uiImage{
                        let index = strongSelf.tentAssets.count
                        strongSelf.tentAssets.append(tent.toTentItem(index: index, image: Image(uiImage: uiImage)))
                    }
                }
            }
        }
    }
        
}

//MARK: - FIRESTORE VIEWMODEL LOAD IMAGES
extension FirestoreViewModel{
    func loadTentImagesFromLocal(_ imageNames:[String],completion: @escaping ([UIImage]) -> Void){
        ServiceManager.loadImagesFromBundle("Tent",
                                            imageNames: imageNames){ images in
            DispatchQueue.main.async { completion(images) }
        }
                                            
    }
  
    func loadTentImagesFromServer(_ imageNames:[String],completion: @escaping (UIImage) -> Void){
        for imageName in imageNames{
            downloadTentIconImageFromStorage(tentId: imageName){ error,uiImage in
                if let uiImage = uiImage{
                    completion(uiImage)
                }
            }
        }
     }
}

//MARK: - FIRESTORE VIEWMODEL DOWNLOAD DATA
extension FirestoreViewModel{
    func downloadTentIconImageFromStorage(tentId:String,
                                          onResult:((Error?,UIImage?) -> Void)? = nil){
        let ref = repo.tentIconReference(tentId: tentId)
        ref.getData(maxSize: (MAX_STORAGE_PNG_SIZE)){ (data, error) in
            if let data = data,
               let uiImage = UIImage(data: data){
               onResult?(nil,uiImage)
            }
            else if let error = error{ 
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_IMAGE(message:error.localizedDescription),nil)
            }
            else{
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_IMAGE(),nil)
            }
       }
    }
    
    func downloadTentModelFromStorage(tentId:String, 
                                      onResult:((Error?,Data?) -> Void)? = nil){
        let ref = repo.tentModelReference(tentId: tentId)
        ref.getData(maxSize: (MAX_STORAGE_USDZ_SIZE)){ (data, error) in
            if let data = data { onResult?(nil,data) }
            else if let error = error{
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_MODEL(message:error.localizedDescription),nil)
            }
            else{
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_MODEL(),nil)
            }
       }
    }
}

//MARK: - FIRESTORE VIEWMODEL UPLOAD DATA
extension FirestoreViewModel{
    func uploadTentAssetsFromJson(){
        ServiceManager.readJsonFromBundleFile("data.json",value: TentDb.self){ [weak self] data in
            if let strongSelf = self,
               let data = data{
                for obj in data{
                    guard let tentId = obj.id else { continue }
                    let doc = strongSelf.repo.tentDocument(tentId: tentId)
                    do{
                        try doc.setData(from:obj){ err in
                            if let _ = err{
                                //debugLog(object: err.localizedDescription)
                            }
                        }
                    }
                    catch{
                        //debugLog(object: error.localizedDescription)
                    }
                }
            }
        }
    }
}

//MARK: - FIRESTORE VIEWMODEL COLLECTION COUNT
extension FirestoreViewModel{
    func tentCollectionCount(_ tentId:String){
        let ref = repo.tentCollection()
        let tentCount = ref.count
        tentCount.getAggregation(source: .server){ snapShot,error in
            if let snapShot = snapShot{
                debugLog(object: snapShot.count)
            }
            else{
                debugLog(object: error?.localizedDescription ?? "")
            }
        }
    }
}

//MARK: - FIRESTORE VIEWMODEL HELPER
extension FirestoreViewModel{
    var hasTents:Bool{
        tentAssets.count > 0
    }
    
    func updateLoadingStateWith(value state:Bool){
        self.isLoadingData = state
    }
}

