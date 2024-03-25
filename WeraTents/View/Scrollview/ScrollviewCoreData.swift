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
    let layout = [
            GridItem(),
            GridItem(),
    ]
    var content: (NSManagedObject) -> Content
     
    var body: some View{
        GeometryReader{ reader in
            ScrollView {
                LazyVGrid(columns: [GridItem(),GridItem()],
                          alignment: .center,
                          spacing: V_GRID_SPACING,
                          pinnedViews: .sectionHeaders){
                    ForEach(Array(zip(coreDataViewModel.items.indices,
                                      coreDataViewModel.items)),id:\.0){ index, model in
                        content(model)
                            .id(model.id)
                            .onAppear {
                                coreDataViewModel.requestMoreItemsIfNeeded(index: index)
                            }
                    }
                    
                }
                .padding(.horizontal)
                .padding(.bottom,MENU_HEIGHT)
            }
            .scrollIndicators(.hidden)
            .overlay {
                if coreDataViewModel.dataIsLoading {
                    SpinnerAnimation(imageSize:reader.min()/2.0)
                }
            }
        }
    }
    
}
