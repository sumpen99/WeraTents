//
//  FirestoreViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import OrderedCollections
enum DbPath:String{
    case WERA           = "Wera"
    case WERA_TENTS     = "Wera_Tents"
    case TENT_ICONS     = "Icons"
    case TENT_MODELS    = "Models"
    case TENT_PDF       = "Pdf"
}

enum LoadingState:Int,CaseIterable{
    case TENT_ASSETS
    case ICON_OPTIONAL
    case USDZ_MODEL
    case PDF_DOCUMENT
}

//MARK: - FIRESTORE REPOSITORY
class FirestoreRepository{
    private let dB = Firestore.firestore()
    private let storage = Storage.storage()
    
    func shutDown(){
        dB.terminate()
    }
    
    func weraCollection() -> CollectionReference{
        let base = DbPath.WERA.rawValue
        return dB.collection(base)
    }
    
    func weraDocument() -> DocumentReference{
        let base = DbPath.WERA.rawValue
        return dB.collection(base).document(base)
    }
    
    func tentCollection() -> CollectionReference{
        let collection = DbPath.WERA_TENTS.rawValue
        return dB.collection(collection)
    }
    
    func tentDocument(tentId:String) -> DocumentReference{
        let base = DbPath.WERA_TENTS.rawValue
        return dB.collection(base).document(tentId)
    }
     
    func tentIconReference(fileName:String) -> StorageReference{
        let folder = DbPath.TENT_ICONS.rawValue
        let path = "\(folder)/\(fileName).png"
        return storage.reference(withPath: path)
    }
    
    func tentModelReference(fileName:String) -> StorageReference{
        let folder = DbPath.TENT_MODELS.rawValue
        let path = "\(folder)/\(fileName).usdz"
        return storage.reference(withPath: path)
    }
    
    func tentPdfReference(fileName:String) -> StorageReference{
        let folder = DbPath.TENT_PDF.rawValue
        let path = "\(folder)/\(fileName).pdf"
        return storage.reference(withPath: path)
    }
}

//MARK: - FIRESTORE VIEWMODEL
class FirestoreViewModel:ObservableObject{
    @Published var isLoadingData:[Bool] = Array.init(repeating: false, 
                                                     count: LoadingState.allCases.count)
    @Published var tentAssets:[TentItem] = []
    @Published var weraAsset:Wera?
    let repo = FirestoreRepository()
}

//MARK: - LOAD WERA ASSETS DATA
extension FirestoreViewModel{
    func loadWeraAssets(){
        if FETCH_LOCALLY{ loadWeraAssetsFromLocal() }
        else{ loadWeraAssetsFromServer() }
    }
    
    private func loadWeraAssetsFromLocal(){
        ServiceManager.readJsonFromBundleFile("mainData.json",value: WeraDb.self){ [weak self] data in
            if let strongSelf = self,
                let data = data{
                let wera = data.toWera()
                DispatchQueue.main.async {
                    strongSelf.weraAsset = wera
                }
            }
        }
    }
    
    private func loadWeraAssetsFromServer(){
        let coll = repo.weraCollection()
        let task = coll.getDocuments(){ [weak self] snapshot,error in
        guard let strongSelf = self,
              let snapshot = snapshot,
              let document = snapshot.documents.first else { return }
            
            if let weraDb = try? document.data(as : WeraDb.self){
                let wera = weraDb.toWera()
                strongSelf.weraAsset = wera
            }
        }
    }
}

//MARK: - LOAD TENT MODEL DATA
extension FirestoreViewModel{
    func loadTentModelData(_ fileName:String,completion: @escaping (URL?) -> Void){
        if  FETCH_LOCALLY{
            let url = ServiceManager.localUSDZUrl(fileName: fileName)
            completion(url)
        }
        else{
            if let url = ServiceManager.fileExistInside(folder: .USDZ,
                                                        fileName: fileName,
                                                        ext: TempFolder.USDZ.rawValue){
                completion(url)
            }
            else{ downloadTentModelFromStorage(fileName, completion: completion) }
        }
    }
}

//MARK: - LOAD TENT PDF DATA
extension FirestoreViewModel{
    func loadTentPdfData(_ fileName:String,completion: @escaping (URL?) -> Void){
        if  FETCH_LOCALLY{
            let url = ServiceManager.localPDFUrl(fileName: fileName)
            completion(url)
        }
        else{
            if let url = ServiceManager.fileExistInside(folder: .PDF,
                                                        fileName: fileName,
                                                        ext: TempFolder.PDF.rawValue){
                completion(url)
            }
            else{ downloadTentPdfFromStorage(fileName, completion: completion) }
        }
    }
    
}

//MARK: - LOAD IMAGES
extension FirestoreViewModel{
    func currentIconImage(_ iconImageUrl:String,
                          completion: @escaping (UIImage?) -> Void){
        if FETCH_LOCALLY{
            loadTentImagesFromLocal([iconImageUrl]){ images in
                completion(images.first)
            }
        }
        else{
            downloadTentIconImageFromStorage(fileName: iconImageUrl){ error,uiImage in
                completion(uiImage)
            }
        }
    }
    
    
    func loadTentImagesFromLocal(_ imageNames:[String],completion: @escaping ([UIImage]) -> Void){
        ServiceManager.loadImagesFromBundle("Tent",
                                            imageNames: imageNames){ images in
            DispatchQueue.main.async { completion(images) }
        }
    }
  
    func loadTentImagesFromServer(_ imageNames:[String],completion: @escaping (UIImage) -> Void){
        for imageName in imageNames{
            downloadTentIconImageFromStorage(fileName: imageName){ error,uiImage in
                if let uiImage = uiImage{
                    completion(uiImage)
                }
            }
        }
     }
}

//MARK: - DOWNLOAD DATA
extension FirestoreViewModel{
    func downloadTentIconImageFromStorage(fileName:String,
                                          onResult:((Error?,UIImage?) -> Void)? = nil){
        let ref = repo.tentIconReference(fileName: fileName)
        ref.getData(maxSize: (MAX_STORAGE_PNG_SIZE)){ (data, error) in
            if let data = data,
               let uiImage = UIImage(data: data){
               onResult?(nil,uiImage)
            }
            else{
                onResult?(nil,UIImage(systemName: "photo"))
            }
       }
    }
   
    func downloadTentModelFromStorage(_ fileName:String,completion: @escaping (URL?) -> Void){
        if let localUrl = ServiceManager.create(file: fileName,folder: .USDZ,ext: TempFolder.USDZ.rawValue){
            let ref = repo.tentModelReference(fileName: fileName)
            ref.write(toFile: localUrl) { url, error in
                completion(url)
            }
       }
       else{ completion(nil) }
    }
    
    func downloadTentPdfFromStorage(_ fileName:String,completion: @escaping (URL?) -> Void){
        if let localUrl = ServiceManager.create(file: fileName,folder: .PDF,ext: TempFolder.PDF.rawValue){
            let ref = repo.tentPdfReference(fileName: fileName)
            ref.write(toFile: localUrl) { url, error in
                completion(url)
            }
       }
       else{ completion(nil) }
    }
}

//MARK: - COLLECTION COUNT
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

//MARK: ORDERED-DICTIONARY
extension FirestoreViewModel{
    func catalogeList() -> [String]{
        if let weraAsset = weraAsset,
           let cataloge = weraAsset.cataloge{
            return cataloge.keys.elements
        }
        return []
    }
    
    func currentBrandsOfCataloge(cataloge label:String?) -> [String]{
        if let weraAsset = weraAsset,
           let cataloge = weraAsset.cataloge,
           let label = label,
           let brands = cataloge[label]?.brands{
            return brands.keys.elements
        }
        return []
    }
    
    func currentModelsOfBrand(cataloge label:String?,
                              brand:String?) -> [String]{
        if let weraAsset = weraAsset,
           let cataloge = weraAsset.cataloge,
           let label = label,
           let brand = brand,
           let brands = cataloge[label]?.brands,
           let tents = brands[brand]?.tents{
            return tents.keys.elements
        }
        return []
    }
    
    func currentTentItem(cataloge label:String?,
                         brand:String?,
                         modelId:String?) -> Tent?{
        if let weraAsset = weraAsset,
           let cataloge = weraAsset.cataloge,
           let label = label,
           let brand = brand,
           let modelId = modelId,
           let brands = cataloge[label]?.brands,
           let tents = brands[brand]?.tents,
           let tent = tents[modelId]{
           return tent
        }
        return nil
    }
    
    func currentBrandItem(cataloge label:String?,
                         brand:String?) -> Brand?{
        if let weraAsset = weraAsset,
           let cataloge = weraAsset.cataloge,
           let label = label,
           let brand = brand,
           let brands = cataloge[label]?.brands,
           let brand = brands[brand]{
           return brand
        }
        return nil
    }
    
    func currentCatalogeItem(cataloge label:String?) -> Cataloge?{
        if let weraAsset = weraAsset,
           let cataloge = weraAsset.cataloge,
           let label = label,
           let catalogeItem = cataloge[label]{
           return catalogeItem
        }
        return nil
    }
    
}

//MARK: - HELPER FUNCTIONS
extension FirestoreViewModel{
    
    func loadingState(_ state:LoadingState) -> Bool{
        return self.isLoadingData[state.rawValue]
    }
    
    func updateLoadingStateWith(state:LoadingState,value:Bool){
        if self.isLoadingData[state.rawValue] == value { return }
        self.isLoadingData[state.rawValue] = value
    }
}

//MARK: - UPLOAD DATA
extension FirestoreViewModel{
    func uploadTentAssetsFromJson(){
        ServiceManager.readJsonFromBundleFile("mainData.json",value: WeraDb.self){ [weak self] data in
            if let strongSelf = self,
               let data = data{
                let doc = strongSelf.repo.weraDocument()
                do{
                    try doc.setData(from:data){ err in
                        if let err = err{ debugLog(object: err.localizedDescription) }
                    }
                }
                catch{ debugLog(object: error.localizedDescription) }
            }
        }
    }
}
