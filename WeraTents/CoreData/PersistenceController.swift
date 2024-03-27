//
//  PersistenceController.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI
import CoreData

enum CoreDataError:Error{
    case SAVE_FAILED(String)
}

final class PersistenceController {
    typealias YEAR = String
    typealias MONTH = String
    typealias DAY = String
    typealias FETCH_RECORD = [YEAR:[MONTH:[DAY:Int]]]
    static let shared = PersistenceController()

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeraDataModel")
        container.loadPersistentStores{ description,error in
            if let error = error {
                fatalError("Unable to load persistent store \(error)")
            }
        }
        //container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    private init(){ }
    
}

//MARK: - UPDATE
extension PersistenceController{
    static func updateScreenshot(_ model:ScreenshotModel,with comment:String){
        
        model.setValue(comment, forKey: "shortDesc")
        saveChanges()
    }
}

//MARK: - FETCH
extension PersistenceController{
    
    static func fetchCountWithoutPredicate() -> Int {
        var count: Int = 0
        shared.container.viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"ScreenshotModel")
            fetchRequest.resultType = NSFetchRequestResultType.countResultType
            do {
                count = try shared.container.viewContext.count(for: fetchRequest)
            } catch {
                debugLog(object: "\(error)")
             }
        }
        return count
    }
}

//MARK: - SAVE
extension PersistenceController {
    public func saveContext(backgroundContext:NSManagedObjectContext? = nil) throws{
        let context = backgroundContext ?? container.viewContext
        guard context.hasChanges else { throw CoreDataError.SAVE_FAILED("Context has no changes") }
        try context.save()
        
    }
    
    static func saveContext(backgroundContext:NSManagedObjectContext? = nil) throws{
        let context = backgroundContext ?? shared.container.viewContext
        guard context.hasChanges else { throw CoreDataError.SAVE_FAILED("Context has no changes") }
        try context.save()
    }
    
    static func saveChanges(){
        do {
            try saveContext()
        } catch {
            debugLog(object: error.localizedDescription)
        }
    }
}

//MARK: - DELETE
extension PersistenceController {
   
    static func deleteAllDataFromEntity(_ name:String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:name)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try shared.container.viewContext.execute(batchDeleteRequest)
        } catch {
            debugLog(object: error.localizedDescription)
        }
    }
    
    static func deleteScreenshotModel(_ meta: ScreenshotModel?){
        guard let meta = meta else { return }
        shared.container.viewContext.delete(meta)
    }
    
    static func deleteScreenshotImage(_ image: ScreenshotImage?){
        guard let image = image else { return }
        shared.container.viewContext.delete(image)
    }
    
    static func deleteMultipleItems(models:[CoreDataRemoveItem],completion:@escaping (Bool,Bool) -> Void){
        DispatchQueue.global(qos: .background).async {
            let modelIds = models.map({$0.modelId})
            let imageIds = models.map({$0.imageId})
            DispatchQueue.main.async {
                let modelResult = items(toDelete: modelIds)
                let imageResult = items(toDelete: imageIds)
                completion(modelResult,imageResult)
            }
        }
   }
    
    static func items(toDelete itemIds:[NSManagedObjectID]) -> Bool{
        do {
            let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: itemIds)
            try shared.container.viewContext.executeAndMergeChanges(using: batchDeleteRequest)
            return true
        }
        catch {
            //debugLog(object: error.localizedDescription)
            return false
        }
    }
}


//MARK: - NSManagedObjectContext
//https://stackoverflow.com/questions/14560900/coredata-delete-multiple-objects
//https://www.avanderlee.com/swift/nsbatchdeleterequest-core-data/
extension NSManagedObjectContext {
    
  public func executeAndMergeChanges(using batchDeleteRequest: NSBatchDeleteRequest) throws {
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        let result = try execute(batchDeleteRequest) as? NSBatchDeleteResult
        let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}

