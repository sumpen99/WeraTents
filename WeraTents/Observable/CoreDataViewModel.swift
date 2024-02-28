//
//  CoreDataViewModel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

class CoreDataViewModel:ObservableObject{
    
    private let itemsFromEndThreshold = 10
    
    private var totalItemsAvailable: Int?
    private var itemsLoadedCount: Int?
    private var page = 0
    
    private let coreDataFetcher: CoreDataService = CoreDataService()
    
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

