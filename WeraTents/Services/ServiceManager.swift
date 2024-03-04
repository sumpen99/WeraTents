//
//  FileManager.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//
import SwiftUI

class ServiceManager{
    
    static func readAssetsFromBundle(_ bundle:String) -> [String]{
        let fileManager = FileManager.default
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent(bundle)
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: assetURL, includingPropertiesForKeys: [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey, URLResourceKey.pathKey], options: .skipsHiddenFiles)
            return contents.map { $0.lastPathComponent }
        }
        catch let error as NSError {
            debugLog(object: error)
        }
        return []
    }
    
    static func readJsonFromBundleFile<T:Decodable>(_ file:String,
                                                    value:T.Type,
                                                    completion: @escaping ([T]?) -> Void){
        DispatchQueue.global(qos: .background).async {
            let tentItems = Bundle.main.decode([T].self, from: "data.json")
            completion(tentItems)
        }
    }
    
    static func loadImageFromBundle(_ asset:String,
                                    imageName:String,
                                    completion: @escaping (UIImage?) -> Void){
        
        DispatchQueue.global(qos: .background).async {
            if let bundlePath = Bundle.main.path(forResource: asset, ofType: "bundle"),
               let bundle = Bundle(path: bundlePath),
               let resourcePath = bundle.path(forResource: imageName, ofType: "png"){
                DispatchQueue.main.async { completion(UIImage(contentsOfFile: resourcePath)) }
            }
        }
    }
        
    
    static func loadImagesFromBundle(_ asset:String,
                                     imageNames:[String],
                                     completion: @escaping ((OperationResult?,[TentItem]?) -> Void)){
        /*
         let imageNames = ServiceManager.readAssetsFromBundle("Tent.bundle")
         ServiceManager.loadImagesFromBundle("Tent", imageNames: imageNames){}
         */
        DispatchQueue.global(qos: .background).async {
            var tentItems:[TentItem] = []
            if let bundlePath = Bundle.main.path(forResource: asset, ofType: "bundle"),
               let bundle = Bundle(path: bundlePath){
                for name in imageNames{
                    let splitName = name.components(separatedBy: ".")
                    if splitName.count != 2 { continue }
                    if let resourcePath = bundle.path(forResource: splitName[0], ofType: splitName[1]),
                       let uiImage = UIImage(contentsOfFile: resourcePath){
                        tentItems.append(TentItem(id:shortId(),
                                                  index:tentItems.count,
                                                  name: String(splitName[0]).capitalized,
                                                  img: Image(uiImage: uiImage)))
                    }
                }
            }
            DispatchQueue.main.async {
                completion(nil,tentItems)
            }
            
        }
        
    }
}
