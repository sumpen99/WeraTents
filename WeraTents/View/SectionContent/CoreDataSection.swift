//
//  CoreDataLatestSection.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-24.
//

import SwiftUI
import CoreData
struct CoreDataSection:View {
    @StateObject var coreDataViewModel:CoreDataViewModel
    init(){
        self._coreDataViewModel = StateObject(wrappedValue: CoreDataViewModel())
    }
    
    var body:some View{
        screenShotList
        .task{
            coreDataViewModel.requestInitialSetOfItems()
        }
        .onDisappear{
            coreDataViewModel.clearAllData()
        }
    }
    
}

//MARK: - CONTENT
extension CoreDataSection{
    var screenShotList:some View{
        LazyVGrid(columns: [GridItem(),GridItem()],
                  alignment: .center,
                  spacing: V_GRID_SPACING,
                  pinnedViews: .sectionHeaders){
            ForEach(coreDataViewModel.items,id:\.self){ screenShot in
                screenshotCard(screenShot)
                .padding(.vertical)
             }
                                                            
        }
        .padding(.horizontal)
        .padding(.bottom,MENU_HEIGHT)
    }
    
    @ViewBuilder
    func screenshotCard(_ model:ScreenshotModel) -> some View{
        if let image = model.image,
           let imageData = image.data,
           let uiImage = UIImage(data: imageData){
            FlippedCard(image: Image(uiImage: uiImage),
                        label: model.label,
                        modelId: model.modelId,
                        labelText: model.name ?? "",
                        descriptionText: model.shortDesc ?? "",
                        dateText: model.date?.toISO8601String() ?? "")
                        { newComment in
                            PersistenceController
                            .updateScreenshot(model,with: newComment)}
                }
    }
}
