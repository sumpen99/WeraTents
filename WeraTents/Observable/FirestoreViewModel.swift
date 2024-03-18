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

struct BrandIndexes{
    typealias MODEL_ID = String
    var startIndex:Int
    var endIndex:Int
    var count:Int = 1
    var modelIds:OrderedDictionary<MODEL_ID,Int>
    
    init(startIndex: Int, endIndex: Int,modelId:String) {
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.modelIds = [modelId:startIndex]
    }
}

//MARK: - FIRESTORE VIEWMODEL
class FirestoreViewModel:ObservableObject{
    typealias  BRAND = String
    @Published var isLoadingData:[Bool] = Array.init(repeating: false, 
                                                     count: LoadingState.allCases.count)
    @Published var tentAssets:[TentItem] = []
    @Published var brandAsset:OrderedDictionary<BRAND,BrandIndexes> = [:]
    let repo = FirestoreRepository()
    
}

//MARK: - LOAD TENT ASSETS DATA
extension FirestoreViewModel{
    
    func loadTentAssets(){
        if FETCH_LOCALLY{ loadTentAssetsFromLocal() }
        else{ loadTentAssetsFromServer() }
    }
    
    private func loadTentAssetsFromLocal(){
        ServiceManager.readJsonFromBundleFile("data.json",value: TentDb.self){ [weak self] data in
            if let strongSelf = self,
               let data = data{
                for tent in data.sorted(by: <){
                    ServiceManager.loadImagesFromBundle("Tent",
                                                       imageNames: [tent.iconStorageIds?[0] ?? ""]){ uiImages in
                        if let uiImage = uiImages.first{
                            let count = strongSelf.tentAssets.count
                            strongSelf.updateBrandAssetsIndexes(with: tent.label,
                                                                index: count,
                                                                modelId:tent.modelId)
                            strongSelf.tentAssets.append(tent.toTentItem(index: count, image: Image(uiImage: uiImage)))
                            strongSelf.updateLoadingStateWith(state: .TENT_ASSETS, value: false)
                        }
                     }
                }
            }
        }
    }
     
    private func loadTentAssetsFromServer(){
        let coll = repo.tentCollection()
        coll.order(by: "label",descending: true)
            .order(by: "modelId", descending: true)
            .getDocuments(){ [weak self] snapshot,error in
            guard let strongSelf = self,
                  let snapshot = snapshot else { return }
            for doc in snapshot.documents{
                guard let tent = try? doc.data(as : TentDb.self),
                      let iconUrl = tent.iconStorageIds?[0]
                else{ continue }
                strongSelf.downloadTentIconImageFromStorage(fileName: iconUrl){ error,uiImage in
                    if let uiImage = uiImage{
                        let count = strongSelf.tentAssets.count
                        strongSelf.updateBrandAssetsIndexes(with: tent.label,
                                                            index: count,
                                                            modelId:tent.modelId)
                        strongSelf.tentAssets.append(tent.toTentItem(index: count, image: Image(uiImage: uiImage)))
                        strongSelf.updateLoadingStateWith(state: .TENT_ASSETS, value: false)
                    }
                    else if let error = error{
                        debugLog(object: error.localizedDescription)
                    }
                }
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
            /*else if let error = error{
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_IMAGE(message:error.localizedDescription),nil)
            }
            else{
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_IMAGE(),nil)
            }*/
       }
    }
     /*
    func downloadTentModelFromStorage(fileName:String,
                                      onResult:((Error?,Data?) -> Void)? = nil){
        let ref = repo.tentModelReference(fileName: fileName)
        ref.getData(maxSize: (MAX_STORAGE_USDZ_SIZE)){ (data, error) in
            if let data = data { onResult?(nil,data) }
            else if let error = error{
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_MODEL(message:error.localizedDescription),nil)
            }
            else{
                onResult?(PresentedError.FAILED_TO_DOWNLOAD_MODEL(),nil)
            }
       }
    }*/
    
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

//MARK: - UPLOAD DATA
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
                            if let err = err{ debugLog(object: err.localizedDescription) }
                        }
                    }
                    catch{ debugLog(object: error.localizedDescription) }
                }
            }
        }
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

//MARK: - SPLIT TENT INTO PARTS
extension FirestoreViewModel{
    func brandRange(_ label:String?) ->Range<Int>{
        if let label = label,
           let brandAsset = brandAsset[label]{
            return (brandAsset.startIndex..<brandAsset.endIndex+1)
        }
        return (0..<0)
    }
}

//MARK: - HELPER FUNCTIONS
extension FirestoreViewModel{
    
    var firstBrand:String?{
        tentAssets.first?.label
    }
    
    var hasTents:Bool{
        tentAssets.count > 0
    }
    
    var assetCount:Int{
        tentAssets.count
    }
     
    func secureTentItem(brand:String?,modelId:String?) -> TentItem?{
        if let brand = brand,
           let modelId = modelId,
           let index = brandAsset[brand]?.modelIds[modelId]{
           return secureTentItem(index)
        }
        return nil
    }
    
    func secureTentItemIndex(brand:String?,modelId:String?) -> Int?{
        if let brand = brand,
           let modelId = modelId,
           let index = brandAsset[brand]?.modelIds[modelId]{
           return index
        }
        return nil
    }
    
    func secureTentItem(_ index:Int) -> TentItem?{
        if 0 <= index && index < assetCount{
            return tentAssets[index]
        }
        return nil
    }
    
    func secureModelList(_ brand:String?) -> [String]{
        guard let brand = brand,
              let asset = brandAsset[brand] else{ return [] }
        return asset.modelIds.keys.elements
    }
    
    func initializeFirstModelOfBrand(_ brand:String?) -> String?{
        if let brand = brand,
           let asset = brandAsset[brand]{
            return asset.modelIds.keys.first
        }
        return nil
    }
    
    func updateBrandAssetsIndexes(with brand:String?,index:Int,modelId:String?){
        if let brand = brand,
           let modelId=modelId{
            if let _ = brandAsset[brand]{
                brandAsset[brand]?.endIndex = index
                brandAsset[brand]?.modelIds[modelId] = index
            }
            else{
                brandAsset[brand] = BrandIndexes(startIndex: index,endIndex: index,modelId:modelId)
            }
            
        }
    }
    
    func loadingState(_ state:LoadingState) -> Bool{
        return self.isLoadingData[state.rawValue]
    }
    
    func updateLoadingStateWith(state:LoadingState,value:Bool){
        if self.isLoadingData[state.rawValue] == value { return }
        self.isLoadingData[state.rawValue] = value
    }
}
