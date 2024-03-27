//
//  CoreDataViewModel.swift
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

//MARK: - COREDATA-FETCHER
class CoreDataFetcher{
    let CORE_DATA_FETCH_LIMIT = 500
    
    var totalItems:Int = 0
    var totalPages:Int = 0
    var currentPage:Int = 0
    
    func incremeantPageIndex(){ currentPage += 1 }
    var nextOffset:Int{ currentPage * CORE_DATA_FETCH_LIMIT }
    var hasDataToFetch:Bool{ currentPage < totalPages && totalItems > 0 }
}

//MARK: - COREDATA-FETCHER REQUEST ITEMS
extension CoreDataFetcher{
    
    func requestItemsByPage(_ page:Int,onResult: @escaping ((totalItems:Int,items:[ScreenshotModel])) -> Void) {
        if hasDataToFetch{
            let nextOffset = nextOffset
            let fetchLimit = CORE_DATA_FETCH_LIMIT
            incremeantPageIndex()
            DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
                if let strongSelf = self{
                    let items = strongSelf.fetchedRequestWithOffset(nextOffset, fetchLimit: fetchLimit)
                    onResult((totalItems:strongSelf.totalItems,items:items))
                }
            }
        }
        onResult((totalItems:totalItems,items:[]))
    }
    
    func fetchedRequestWithOffset(_ fetchOffset:Int,fetchLimit:Int) -> [ScreenshotModel]{
        let fetchRequest: NSFetchRequest<ScreenshotModel> = ScreenshotModel.fetchRequest()
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchOffset = fetchOffset
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            return try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
     }
       
}

//MARK: - COREDATA-FETCHER HELPER
extension CoreDataFetcher{
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
}

//MARK: - COREDATA-VIEWMODEL
class CoreDataViewModel:ObservableObject{
    private let itemsFromEndThreshold = 30
    private var totalItemsAvailable: Int?
    private var itemsLoadedCount: Int?
    private var page = 0
    private let coreDataFetcher: CoreDataFetcher = CoreDataFetcher()
    @Published var items: [ScreenshotModel] = []
    @Published var dataIsLoading = false
}

//MARK: - COREDATA-VIEWMODEL REQUEST ITEMS
extension CoreDataViewModel{
    
    func requestInitialSetOfItems(){
        resetPageCounter()
        requestItems(page: page)
    }
     
    func requestItems(page: Int) {
        dataIsLoading = true
        Task { [weak self] in
            if let strongSelf = self{
                strongSelf.coreDataFetcher.requestItemsByPage(page){ response in
                    DispatchQueue.main.async{
                        strongSelf.totalItemsAvailable = response.totalItems
                        strongSelf.items.append(contentsOf: response.items)
                        strongSelf.itemsLoadedCount = strongSelf.items.count
                        strongSelf.dataIsLoading = false
                    }
                }
            }
        }
   }
    
    func requestMoreItemsIfNeeded(index: Int) {
        guard let itemsLoadedCount = itemsLoadedCount,
              let totalItemsAvailable = totalItemsAvailable else {
            return
        }
        if thresholdMeet(itemsLoadedCount, index) && moreItemsRemaining(itemsLoadedCount, totalItemsAvailable) {
            page += 1
            requestItems(page: page)
        }
    }
    
}

//MARK: - COREDATA-VIEWMODEL HELPER
extension CoreDataViewModel{
    
    var hasItemsLoaded:Bool{
        return items.count > 0
    }
    
    private func thresholdMeet(_ itemsLoadedCount: Int, _ index: Int) -> Bool {
        return (itemsLoadedCount - index) == itemsFromEndThreshold
    }
    
    private func moreItemsRemaining(_ itemsLoadedCount: Int, _ totalItemsAvailable: Int) -> Bool {
        return itemsLoadedCount < totalItemsAvailable
    }
    
    func resetPageCounter(){
        page = 0
        items.removeAll()
        coreDataFetcher.resetPageCounter()
    }
    
}
