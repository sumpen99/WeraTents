//
//  FileManager.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//
import SwiftUI
import AVKit

enum TempFolder:String{
    case USDZ = "usdz"
    case PDF = "pdf"
    case PNG = "png"
    case SCREEN_SHOT = "use_png"
}

struct Folder{
    let existingFolder:URL?
    let freeFolder:URL?
}

class ServiceManager{
    
    static var documentDirectory:URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }
    
    static func localUSDZUrl(fileName:String) -> URL?{
        return Bundle.main.url(forResource: "\(fileName)", withExtension: "usdz")
    }
    
    static func localPDFUrl(fileName:String) -> URL?{
        return Bundle.main.url(forResource: "\(fileName)", withExtension: "pdf")
    }
    
    static func localImageUrl(fileName:String) -> URL?{
        return Bundle.main.url(forResource: "\(fileName)", withExtension: "png")
    }
    
    static func temporaryFileURL(fileName: String,ext: String) -> URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(fileName)
                .appendingPathExtension(ext)
    }
    
    static func canOpenSettingsUrl() -> Bool{
        if let url = URL(string: UIApplication.openSettingsURLString){
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    static func openPrivacySettings(){
        guard let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) else {
                    return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
       
}

//MARK: - PLAY SOUND
extension ServiceManager{
    static var mySound:SystemSoundID = {
        var aSound:SystemSoundID = 1108
        if let soundURL = Bundle.main.url(forResource: "Detection", withExtension: "wav"){
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &aSound)
        } else {
            debugLog(object:"No sound file found")
        }
        return aSound
    }()

    static func play() { AudioServicesPlaySystemSound(mySound) }

    static func prepare() -> SystemSoundID { return mySound }
    
    static func playSystemSound(with systemSoundID:SystemSoundID){
        AudioServicesPlaySystemSoundWithCompletion(systemSoundID,{
            AudioServicesRemoveSystemSoundCompletion(systemSoundID)
            AudioServicesDisposeSystemSoundID(systemSoundID)
        })
    }
}

//MARK: - CREATE FOLDER AND FILES
extension ServiceManager{
    static func create(folder named:TempFolder) ->URL?{
        let folder = statusOfFolder(folder: named)
        if let existingFolder = folder.existingFolder { return existingFolder }
        guard let freeFolderName = folder.freeFolder else { return nil }
        do{
            try FileManager.default.createDirectory(at: freeFolderName,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            return freeFolderName
        }
        catch{
            debugLog(object: error.localizedDescription)
        }
        return nil
        
    }
    
    static func create(file named:String,folder:TempFolder,ext:String) -> URL?{
        guard let folder = create(folder: folder) else { return nil }
        let filePath = "\(named).\(ext)"
        return folder.appending(path: filePath)
    }
}

//MARK: - READ DATA
extension ServiceManager{
    static func readAssetsFromBundle(_ bundle:String) -> [String]{
        let bundleURL = Bundle.main.bundleURL
        let assetURL = bundleURL.appendingPathComponent(bundle)
         do {
            let contents = try FileManager.default.contentsOfDirectory(at: assetURL, 
                                                                       includingPropertiesForKeys: 
                                                                        [URLResourceKey.nameKey,
                                                                         URLResourceKey.isDirectoryKey,
                                                                         URLResourceKey.pathKey],
                                                                       options: .skipsHiddenFiles)
            return contents.map { $0.lastPathComponent }
        }
        catch let error as NSError {
            debugLog(object: error)
        }
        return []
    }
    
    static func readJsonFromBundleFile<T:Decodable>(_ file:String,
                                                    value:T.Type,
                                                    completion: @escaping (T?) -> Void){
        DispatchQueue.global(qos: .background).async {
            let tentItems = Bundle.main.decode(T.self, from: file)
            //let tentItems = Bundle.main.decode(any.self, from: file)
            completion(tentItems)
        }
    }
    
    static func loadImagesFromBundle(_ asset:String,
                                    imageNames:[String],
                                    completion: @escaping ([UIImage]) -> Void){
        var images:[UIImage] = []
        for imageName in imageNames{
            if let bundlePath = Bundle.main.path(forResource: asset, ofType: "bundle"),
               let bundle = Bundle(path: bundlePath),
               let resourcePath = bundle.path(forResource: imageName, ofType: "png"),
               let uiImage = UIImage(contentsOfFile: resourcePath){
                images.append(uiImage)
            }
            else if let uiImage = UIImage(systemName: "photo"){
                images.append(uiImage)
            }
        }
        DispatchQueue.main.async { completion(images) }
    }
}

//MARK: - WRITE DATA
extension ServiceManager{
    static func writeDataToTemporary(_ data:Data,fileName:String,ext:String,completion: @escaping (URL?) -> Void){
        DispatchQueue.global(qos: .background).async {
            if let tempStorageUrl = temporaryFileURL(fileName: fileName,ext:ext){
                let result = FileManager.default.createFile(atPath: tempStorageUrl.path(), contents: data)
                completion(result ? tempStorageUrl : nil)
            }
            else{
                completion(nil)
            }
        }
    }
    
    static func writeImageToCache(fileName toWriteTo:String,
                                  uiImage:UIImage?,
                                  folder:TempFolder = .PNG,completion:@escaping (Bool) -> Void){
         if let url = create(file: toWriteTo, folder: folder, ext: TempFolder.PNG.rawValue),
           let uiImage = uiImage,
           let data = uiImage.pngData(){
           do {
                try data.write(to: url)
                completion(true)
            } catch {
                completion(false)
            }
        }
        completion(false)
    }
    
    static func writeDataToCache(fileName toWriteTo:String,
                                  data:Data?,
                                  folder:TempFolder,
                                  ext:String,
                                  completion:@escaping (URL?) -> Void){
        DispatchQueue.global(qos: .background).async {
            var writtenUrl:URL?
            if let url = create(file: toWriteTo, folder: folder, ext: ext),
               let data = data{
                do {
                    try data.write(to: url)
                    writtenUrl = url
               } catch {
                    debugLog(object: error.localizedDescription)
                }
            }
            DispatchQueue.main.async {
                completion(writtenUrl)
            }
        }
    }
}

//MARK: - FOLDER AND FILE STATUS
extension ServiceManager{
    static func statusOfFolder(folder named:TempFolder) -> Folder{
        guard let documentDirectory = documentDirectory else { return Folder(existingFolder: nil, freeFolder: nil)}
        let folder = documentDirectory.appendingPathComponent(named.rawValue,isDirectory: true)
        do{
            let resourceValues = try folder.resourceValues(forKeys: [.isDirectoryKey])
            if let _ = resourceValues.isDirectory {
                return Folder(existingFolder: folder, freeFolder: nil)
            }
         } catch {
           debugLog(object: error.localizedDescription)
        }
        return Folder(existingFolder: nil, freeFolder: folder)
    }
    
    static func tempFolderContainsFile(fileName:String,ext:String) -> URL?{
        if let url = temporaryFileURL(fileName: fileName, ext: ext){
            return FileManager.default.fileExists(atPath: url.path()) ? url : nil
        }
        return nil
    }
    
    static func folderFilesAt(url path:URL) -> [URL]?{
        return try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
    }
    
    static func getFilePathUrlAt(folder named:TempFolder,fileName:String,ext:String) -> URL?{
        let folder = statusOfFolder(folder: named)
        guard let existingFolder = folder.existingFolder else {
            return nil
        }
        let filePath = "\(fileName).\(ext)"
        let fileUrl = existingFolder.appending(path: filePath)
        return fileUrl
    }
    
    static func fileExistInside(folder named:TempFolder,fileName:String,ext:String) -> URL?{
        guard let fileUrl = getFilePathUrlAt(folder: named, fileName: fileName, ext: ext) else { return nil }
        return FileManager.default.fileExists(atPath: fileUrl.path()) ? fileUrl : nil
    }
}

//MARK: - REMOVE FILES
extension ServiceManager{
    static func clearFolder(folder:TempFolder,completion: @escaping ((Bool) -> Void)){
        DispatchQueue.global(qos: .background).async {
            let folder = statusOfFolder(folder: folder)
            guard let existingFolder = folder.existingFolder else { completion(false);return }
            guard let filePaths = folderFilesAt(url: existingFolder) else { completion(false);return }
            removeFiles(list: filePaths)
            completion(true)
        }
     }
    
    static func removeFiles(list files:[URL]){
        let fileManager = FileManager.default
        for file in files {
            do{ try fileManager.removeItem(at: file) }
            catch{ debugLog(object: error.localizedDescription)}
        }
    }
    
    static func removefileFromFolder(folder named:TempFolder,fileName:String,ext:String){
        DispatchQueue.global(qos: .background).async {
            guard let filePath = getFilePathUrlAt(folder: named, fileName: fileName, ext: ext) else { return }
            do{
                try FileManager.default.removeItem(at: filePath)
            }
            catch{
                debugLog(object: error.localizedDescription)
            }
        }
        
    }
    
    static func removeDataFromTemporary(_ url:URL?,completion: ((Bool) -> Void)? = nil){
        DispatchQueue.global(qos: .background).async {
            do{
                guard let url = url else { completion?(false);return }
                try FileManager.default.removeItem(at: url)
                completion?(true)
            }
            catch{
                debugLog(object: error.localizedDescription)
                completion?(false)
            }
        }
    }
}
