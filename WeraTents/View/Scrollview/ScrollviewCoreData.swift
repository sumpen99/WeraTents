//
//  ScrollviewCoreData.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

import CoreData

struct ScrollViewCoreData<Content: View>: View {
    @ObservedObject var coreDataViewModel:CoreDataViewModel
    @State var currentScrollOffset:CGPoint?
    let layout = [
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
            GridItem(.flexible(minimum: 40)),
    ]
    var content: (NSManagedObject) -> Content
  
    func handleScroll(_ offset: CGPoint) {
        currentScrollOffset = offset
    }
 
    var body: some View{
        if let items = coreDataViewModel.items?.enumerated().map({ $0 }) {
            GeometryReader{ reader in
                ScrollViewReader { proxy in
                    ScrollViewWithOffset(onScroll: handleScroll) {
                        LazyVGrid(columns:layout,spacing: V_GRID_SPACING,pinnedViews: [.sectionHeaders]){
                            ForEach(items,id:\.element.id){ index, model in
                                content(model)
                                    .id(model.id)
                                    .onAppear {
                                        coreDataViewModel.requestMoreItemsIfNeeded(index: index)
                                    }
                            }
                            .onAppear{
                                coreDataViewModel.setScrollViewDimensions(V_SPACING_REG,scrollViewHeight: reader.size.height)
                            }
                        }
                        .padding(.top)
                    }
                    .overlay {
                        if coreDataViewModel.dataIsLoading {
                            SpinnerAnimation()
                                .frame(width: reader.min()/2.0,height: reader.min()/2.0)
                            .foregroundStyle(Color.orange)
                        }
                    }
                    .onAppear{
                        if let itemIdOnTop = coreDataViewModel.itemIdOnTop{
                            proxy.scrollTo(itemIdOnTop)
                        }
                    }
                    .onDisappear{
                        coreDataViewModel.lastScrollOffset = currentScrollOffset
                    }
                
                }
            }
        }
    }
}
