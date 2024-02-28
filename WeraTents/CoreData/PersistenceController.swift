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
        return container
    }()
    
    private init(){ }
    
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
    
    static func deleteAllData(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"ScreenshotModel")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try shared.container.viewContext.execute(batchDeleteRequest)
        } catch {
            debugLog(object: error.localizedDescription)
        }
        saveChanges()
    }
    
    static func deleteScreenshotModel(_ meta: ScreenshotModel?){
        guard let meta = meta else { return }
        shared.container.viewContext.delete(meta)
        saveChanges()
    }
    
    static func deleteScreenshotImage(_ image: ScreenshotImage?){
        guard let image = image else { return }
        shared.container.viewContext.delete(image)
        saveChanges()
    }
    
    static func fetchAndSortYearOfScreenshots(startDate:NSDate,endDate:NSDate) -> FETCH_RECORD{
        let fetchedScreenshotIds = fetchAllDatesDuringCurrentYear(NSPredicate(format: "date >= %@ AND date < %@",
                                                                        startDate,
                                                                        endDate))
        var fetchResult: FETCH_RECORD = [:]
        for obj in fetchedScreenshotIds {
            
            guard let date = obj["date"] as? Date else { continue }
            let o = date.getYearMonthDayFromISO8601Date()
      
            // If we have year else set
            guard let keyYear = fetchResult["\(o.year)"] else{
                fetchResult["\(o.year)"] = ["\(o.month)":["\(o.day)":1]]
                continue
            }
            // If we have year and month else set
            guard let keyMonth = keyYear["\(o.month)"] else{
                fetchResult["\(o.year)"]?["\(o.month)"] = ["\(o.day)":1]
                continue
            }
            // If we have year and month and day else set
            guard let _ = keyMonth["\(o.day)"] else{
                fetchResult["\(o.year)"]?["\(o.month)"]?["\(o.day)"] = 1
                continue
            }
            // Append to year/month/day
            fetchResult["\(o.year)"]?["\(o.month)"]?["\(o.day)"]? += 1
        }
        return fetchResult
    }
    
    static func fetchAllDatesDuringCurrentYear(_ predicate:NSPredicate) -> [NSDictionary]{
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "ScreenshotModel")
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.propertiesToFetch = ["date"]
        fetchRequest.returnsDistinctResults = true
        
        do {
            return try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    static func fetchScreenshotCountById(_ id:String?) -> Int{
        guard let id = id else { return 0 }
        let predicate = NSPredicate(format: "id == %@",id)
        return fetchCountByPredicate(predicate)
    }
    
    static func fetchCountByPredicate(_ predicate:NSPredicate) -> Int {
        var count: Int = 0
        shared.container.viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName:"ScreenshotModel")
            fetchRequest.predicate = predicate
            fetchRequest.resultType = NSFetchRequestResultType.countResultType

            do {
                count = try shared.container.viewContext.count(for: fetchRequest)
            } catch {
                debugLog(object: "\(error)")
             }

        }
        return count
    }
    
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
    
    static func saveChanges(){
        do {
            try saveContext()
        } catch {
            debugLog(object: error.localizedDescription)
        }
    }
    
}
