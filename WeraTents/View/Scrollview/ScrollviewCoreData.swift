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
            GridItem(),
            GridItem(),
    ]
    var content: (NSManagedObject) -> Content
     
    var body: some View{
        if let items = coreDataViewModel.items?.enumerated().map({ $0 }) {
            GeometryReader{ reader in
                ScrollView {
                    LazyVGrid(columns:layout,
                              spacing: V_GRID_SPACING,
                              pinnedViews: [.sectionHeaders]){
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
                }
                .scrollIndicators(.hidden)
                .overlay {
                    if coreDataViewModel.dataIsLoading {
                        SpinnerAnimation(size:reader.min()/2.0)
                    }
                }
            }
            
        }
    }
 
    
}
