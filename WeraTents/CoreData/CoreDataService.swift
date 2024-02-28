//
//  CoreDataLoader.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI
import CoreData

enum SearchCategorie : String{
    case NAME = "Name"
    case ALL = "ALL"
}

class CoreDataService{
    let CORE_DATA_FETCH_LIMIT = 1
    
    var totalItems:Int = 0
    var totalPages:Int = 0
    var currentPage:Int = 0
    
    func incremeantPageIndex(){ currentPage += 1 }
    var nextOffset:Int{ currentPage * CORE_DATA_FETCH_LIMIT }
    var hasDataToFetch:Bool{ currentPage < totalPages && totalItems > 0 }
    
    func reset(){
        totalItems = 0
        totalPages = 0
        currentPage = 0
    }
    
    func resetPageCounter(){
        reset()
        rebuildPageIndex()
    }
    
    func rebuildPageIndex(){
        totalItems = PersistenceController.fetchCountWithoutPredicate()
        totalPages = totalItems/CORE_DATA_FETCH_LIMIT + 1
    }
    
    func requestItems(page:Int,onResult: @escaping ((totalItems:Int,items:[ScreenshotModel])) -> Void) {
        if hasDataToFetch{
            let nextOffset = nextOffset
            let fetchLimit = CORE_DATA_FETCH_LIMIT
            incremeantPageIndex()
            DispatchQueue.global().async{ [weak self] in
                if let strongSelf = self{
                    let items = strongSelf.fetchedRequest(fetchOffset: nextOffset, fetchLimit: fetchLimit)
                    onResult((totalItems:strongSelf.totalItems,items:items))
                }
            }
        }
        onResult((totalItems:totalItems,items:[]))
    }
        
    func fetchedRequest(fetchOffset:Int,fetchLimit:Int) -> [ScreenshotModel]{
        let fetchRequest: NSFetchRequest<ScreenshotModel> = ScreenshotModel.fetchRequest()
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchOffset = fetchOffset
        fetchRequest.fetchLimit = fetchLimit
        //fetchRequest.fetchBatchSize = fetchLimit
        //fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.includesSubentities = true
        do {
            return try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
     }
    
    func requestItemsBySearchCategorie(_ categorie:SearchCategorie,
                                       searchText:String,
                                       onResult: @escaping ((totalItems:Int,items:[ScreenshotModel])) -> Void) {
        DispatchQueue.global().async{ [weak self] in
            if let strongSelf = self{
                let items = strongSelf.fetchedRequestBySearchCategorie(categorie,searchText:searchText)
                onResult((totalItems:items.count,items:items))
            }
            
        }
    }
    
    func fetchedRequestBySearchCategorie(_ categorie:SearchCategorie,searchText:String) -> [ScreenshotModel]{
        guard let predicate = getPredicateBySearchCategorie(categorie,searchText: searchText)
        else{ return [] }
        let fetchRequest: NSFetchRequest<ScreenshotModel> = ScreenshotModel.fetchRequest()
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.includesSubentities = false
        do {
            return try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
     }
    
    func getPredicateBySearchCategorie(_ categorie:SearchCategorie,searchText:String) -> NSPredicate?{
        //predicate = NSPredicate(format: "%K =[c] %@", argumentArray: [#keyPath(TubeModel.message), searchValue])//caseinsensitive
        switch categorie{
            case .NAME:
            return NSPredicate(format: "name contains[c] %@", searchText)
            default:return nil
        }
    }
}
