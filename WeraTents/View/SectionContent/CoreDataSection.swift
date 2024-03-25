//
//  CoreDataLatestSection.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-24.
//

import SwiftUI
import CoreData
struct CoreDataSection:View {
    let limit:Int
    @State var latestScreenShots:[ScreenshotModel] = []
    
    var body:some View{
        content
        .task {
            CoreDataFetcher.loadDataWith(limit: limit,sortedOn: "date"){  items in
                latestScreenShots = items
            }
        }
        .onDisappear{
            latestScreenShots.removeAll()
        }
    }
}

//MARK: - CONTENT
extension CoreDataSection{
    var content:some View{
        LazyVGrid(columns: [GridItem(),GridItem()],
                  alignment: .center,
                  spacing: V_GRID_SPACING,
                  pinnedViews: .sectionHeaders){
             ForEach(latestScreenShots,id:\.self){ item in
                screenshotCard(item)
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
                        dateText: model.date?.toISO8601String() ?? "",
                        height: HOME_CAPTURED_HEIGHT){ newComment in
                PersistenceController.updateScreenshot(model,with: newComment)
            }
       }
    }
}

struct CoreDataSectionList:View {
    @ObservedObject var coreDataViewModel:CoreDataViewModel
    var body:some View{
        content
    }
}

//MARK: - CONTENT
extension CoreDataSectionList{
    var content:some View{
        ScrollView{
            LazyVGrid(columns: [GridItem(),GridItem()],
                      alignment: .center,
                      spacing: V_GRID_SPACING,
                      pinnedViews: .sectionHeaders){
                ForEach(coreDataViewModel.items,id:\.objectID){ item in
                    screenshotCard(item)
                    .padding(.vertical)
                 }
                                                                
            }
            .padding(.horizontal)
        }
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
                        dateText: model.date?.toISO8601String() ?? "",
                        height: HOME_CAPTURED_HEIGHT){ newComment in
                PersistenceController.updateScreenshot(model,with: newComment)
            }
            /*.onTapGesture {
                
                tapGestureAction(model.objectID,image.objectID)
            }*/
           /*.overlay{
                if cardIsSelectedAction(model.objectID){
                    checkmarkCircle()
                }
            }*/
       }
    }
    
    
    
}
