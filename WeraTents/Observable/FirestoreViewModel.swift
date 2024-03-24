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

enum DownloadData{
    case PDF
    case USDZ
}

enum CatalogeFilter{
    case YOUTUBE
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
    @Published var weraAsset:Wera?
    let repo = FirestoreRepository()
}

//MARK: - LOAD WERA ASSETS DATA
extension FirestoreViewModel{
    func loadWeraAssets(){
        if FETCH_LOCALLY{ loadWeraAssetsFromLocal() }
        else{ loadWeraAssetsFromServer() }
    }
    
    func loadWeraAssetsFromLocal(){
        ServiceManager.readJsonFromBundleFile("mainData.json",value: WeraDb.self){ [weak self] data in
            if let strongSelf = self,
                let data = data{
                let wera = data.toWera()
                DispatchQueue.main.async {
                    strongSelf.weraAsset = wera
                    strongSelf.updateLoadingStateWith(state: .TENT_ASSETS, value: false)
                }
            }
        }
    }
    
    func loadWeraAssetsFromServer(){
        let coll = repo.weraCollection()
        coll.getDocuments(){ [weak self] snapshot,error in
        guard let strongSelf = self,
              let snapshot = snapshot,
              let document = snapshot.documents.first else { return }
            DispatchQueue.global(qos: .background).async{
                if let weraDb = try? document.data(as : WeraDb.self){
                    let wera = weraDb.toWera()
                    DispatchQueue.main.async {
                        strongSelf.weraAsset = wera
                        strongSelf.updateLoadingStateWith(state: .TENT_ASSETS, value: false)
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
            let bundleUrl = ServiceManager.localUSDZUrl(fileName: fileName)
            completion(bundleUrl)
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
            downloadTentIconImageFromStorage(fileName: iconImageUrl,completion: completion)
        }
    }
    
    
    func loadTentImagesFromLocal(_ imageNames:[String],completion: @escaping ([UIImage]) -> Void){
        ServiceManager.loadImagesFromBundle("Tent",imageNames: imageNames){ images in
            DispatchQueue.main.async { completion(images) }
        }
    }
  
}

//MARK: - DOWNLOAD DATA
extension FirestoreViewModel{
    func downloadTentIconImageFromStorage(fileName:String,
                                          completion: @escaping (UIImage?) -> Void){
        let ref = repo.tentIconReference(fileName: fileName)
        ref.getData(maxSize: (MAX_STORAGE_PNG_SIZE)){ (data, error) in
            if let data = data,
               let uiImage = UIImage(data: data){
                completion(uiImage)
            }
            else{
                completion(nil)
            }
       }
    }
    
    func downloadDataFromStorage(_ fileName:String,data:DownloadData,completion: @escaping (URL?) -> Void){
        if FETCH_LOCALLY{
            switch data {
                case .PDF:
                let bundleUrl = ServiceManager.localPDFUrl(fileName: fileName)
                completion(bundleUrl)
                case .USDZ:
                let bundleUrl = ServiceManager.localUSDZUrl(fileName: fileName)
                completion(bundleUrl)
            }
        }
        else{
            switch data {
                case .PDF:
                downloadTentPdfFromStorage(fileName,completion: completion)
                case .USDZ:
                downloadTentModelFromStorage(fileName,completion: completion)
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

//MARK: - ORDERED-DICTIONARY
extension FirestoreViewModel{
    func catalogeList() -> [String]{
        if let weraAsset = weraAsset,
           let cataloge = weraAsset.cataloge{
            return cataloge.keys.elements
        }
        return []
    }
    
    func catalogeByFilter(on filter:CatalogeFilter,
                          completion:@escaping ([CatalogeBrand]) -> Void){
        DispatchQueue.global(qos: .background).async {[weak self] in
            var filteredCataloge:[CatalogeBrand] = []
            if let weraAsset = self?.weraAsset,
               let cataloge = weraAsset.cataloge{
               switch filter {
               case .YOUTUBE:
                   filteredCataloge = self?.filterOnMovies(cataloge) ?? []
               }
            }
            DispatchQueue.main.async {
                completion(filteredCataloge)
            }
        }
         
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

    func tentItemsBy(brand_category toSplit:String?) -> [Tent]{
        guard let toSplit = toSplit else{ return [] }
        let sub_sequence = toSplit.split(separator: "-")
        if sub_sequence.count == 2{
            if let category = sub_sequence.last,
               let brand = sub_sequence.first{
                return tentItemsBy(category: String(category),
                                  brand: String(brand))
            }
        }
        return []
    }
    
    func tentItemsBy(category:String?,brand:String?) -> [Tent]{
        var tentItems:[Tent] = []
        if let category = category,
           let brand = brand,
           let weraAsset = weraAsset,
           let catalogeItems = weraAsset.cataloge,
           let brands = catalogeItems[category]?.brands,
           let tents = brands[brand]?.tents{
                tentItems.append(contentsOf: tents.values)
        }
        return tentItems
    }
    
    func everyTentItem(onResult:@escaping ([Tent]) -> Void){
        DispatchQueue.global(qos: .background).async { [weak self] in
            var tentItems:[Tent] = []
            if let weraAsset = self?.weraAsset,
               let cataloge = weraAsset.cataloge,
               let brands = weraAsset.brands{
                for brand_category in brands{
                    let brand_category_values = brand_category.split(separator: "-")
                    if brand_category_values.count == 2{
                        if let brand = brand_category_values.first,
                           let category = brand_category_values.last,
                           let brands = cataloge[String(category)]?.brands,
                           let tents = brands[String(brand)]?.tents{
                            tentItems.append(contentsOf: tents.values)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                onResult(tentItems)
            }
        }
     }
}

//MARK: - ORDERED-DICTIONARY-YOUTUBE
extension FirestoreViewModel{
    func filterOnMovies(_ cataloge:OrderedDictionary<String,Cataloge>) -> [CatalogeBrand]{
        var filteredCataloge:[CatalogeBrand] = []
        for member in cataloge.keys.elements{
            if let member = cataloge[member],
               let type = member.type,
               let videos = member.instructionVideoUrls,
               let brands = member.brands{
                if !videos.isEmpty{
                    for brand in brands.keys.elements{
                        if let brand = brands[brand],
                           let label = brand.label,
                           let videos = brand.instructionVideoUrls{
                            if !videos.isEmpty{
                                filteredCataloge.append(CatalogeBrand(id: label,
                                                                      cataloge: type,
                                                                      brand: label))
                            }
                        }
                    }
                }
            }
        }
        return filteredCataloge
    }
    
    func videoItemsBy(_ catalogeBrand:CatalogeBrand) -> [String]{
        if let weraAsset = weraAsset,
           let catalogeItems = weraAsset.cataloge,
           let brands = catalogeItems[catalogeBrand.cataloge]?.brands,
           let videos = brands[catalogeBrand.brand]?.instructionVideoUrls{
            return videos
        }
        return []
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
