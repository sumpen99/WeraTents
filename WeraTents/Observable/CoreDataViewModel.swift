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

class CoreDataFetcher{
    let CORE_DATA_FETCH_LIMIT = 12
    
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
            debugLog(object: "fetch")
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

class CoreDataViewModel:ObservableObject{
    
    private let itemsFromEndThreshold = 3
    
    private var totalItemsAvailable: Int?
    private var itemsLoadedCount: Int?
    private var page = 0
    
    private let coreDataFetcher: CoreDataFetcher = CoreDataFetcher()
    
    var currentScrollOffset: CGPoint?
    var scrollViewHeight:CGFloat?
    var lastScrollOffset: CGPoint?
    var childViewHeight:CGFloat?
    var spacing:CGFloat?
    @Published var items: [ScreenshotModel]? = []
    @Published var dataIsLoading = false
    
    func requestInitialSetOfItems(){
        resetPageCounter()
        requestItems(page: page)
    }
     
    private func requestItems(page: Int) {
        dataIsLoading = true
        Task { [weak self] in
            if let strongSelf = self{
                strongSelf.coreDataFetcher.requestItems(page: page){ response in
                    DispatchQueue.main.async{
                        strongSelf.totalItemsAvailable = response.totalItems
                        strongSelf.items?.append(contentsOf: response.items)
                        strongSelf.itemsLoadedCount = strongSelf.items?.count
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
    
    func requestBySearchCategorie(_ categorie:SearchCategorie,searchText:String,onResult:((Int) ->Void)? = nil){
        dataIsLoading = true
        Task { [weak self] in
            if let strongSelf = self{
                strongSelf.coreDataFetcher.requestItemsBySearchCategorie(categorie,searchText: searchText){ response in
                    DispatchQueue.main.async{
                        strongSelf.resetPageCounter()
                        strongSelf.totalItemsAvailable = response.totalItems
                        strongSelf.items?.append(contentsOf: response.items)
                        strongSelf.itemsLoadedCount = strongSelf.items?.count
                        strongSelf.dataIsLoading = false
                        onResult?(strongSelf.itemsLoadedCount ?? 0)
                    }
                }
            }
            

        }
    }
    
    func getModelById(_ modelId:String) -> ScreenshotModel?{
        if let index = items?.firstIndex(where: {$0.id == modelId}){
            return items?[index]
        }
        return nil
    }
    
}

extension CoreDataViewModel{
    
    var hasItemsLoaded:Bool{
        if let count = items?.count{ return count > 0 }
        return false
    }
    
    var itemIdOnTop: String?{
        if let itemCount = items?.count,
            let spacing = spacing,
            let childViewHeight = childViewHeight,
            let lastScrollOffset = lastScrollOffset,
            let scrollViewHeight = scrollViewHeight{
            let scroll = (lastScrollOffset.y * -1)
            
            let childrenPossiblOnScreen = Int(round(scrollViewHeight/(childViewHeight+spacing)))
            
            let childAtBottomIndex = Int(round(scroll/(childViewHeight+spacing))) + childrenPossiblOnScreen
            
            let newIndex = childAtBottomIndex - childrenPossiblOnScreen
            
            
            if 0 <= newIndex && newIndex < itemCount{
                return items?[newIndex].id
            }
        }
        return nil
    }
    
    private func thresholdMeet(_ itemsLoadedCount: Int, _ index: Int) -> Bool {
        return (itemsLoadedCount - index) == itemsFromEndThreshold
    }
    
    private func moreItemsRemaining(_ itemsLoadedCount: Int, _ totalItemsAvailable: Int) -> Bool {
        return itemsLoadedCount < totalItemsAvailable
    }
    
    func setScrollViewDimensions(_ spacing:CGFloat,scrollViewHeight:CGFloat){
        self.spacing = spacing
        self.scrollViewHeight = scrollViewHeight
    }
    
    func setChildViewDimension(_ childViewHeight:CGFloat){
        self.childViewHeight = childViewHeight
    }
    
    func resetPageCounter(){
        page = 0
        items?.removeAll()
        coreDataFetcher.resetPageCounter()
    }
    
    func clearAllData(){
        page = 0
        items?.removeAll()
        coreDataFetcher.reset()
    }
    
}





