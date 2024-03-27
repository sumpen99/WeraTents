//
//  CapturedImages.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI
import CoreData
enum LibraryState{
    case BASE
    case EDIT
}

struct CoreDataRemoveItem{
    let modelId:NSManagedObjectID
    let imageId:NSManagedObjectID
    
}

struct CapturedImages:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @StateObject var coreDataViewModel:CoreDataViewModel = CoreDataViewModel()
    @State var state:LibraryState = .BASE
    @State var deleteModels:[CoreDataRemoveItem] = []
    @State var expandedImageValues:ExpandedImageValues?
 
    init(){
        self._coreDataViewModel = StateObject(wrappedValue: CoreDataViewModel())
    }
    
    var body: some View {
        appBackgroundGradient
        .ignoresSafeArea(.all)
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .ignoresSafeArea(edges:[.bottom])
        .task{
            coreDataViewModel.requestInitialSetOfItems()
        }
        .overlay{
            if expandedImageValues != nil{
                ExpandedImage(expandedImageValues: $expandedImageValues)
            }
        }
    }
}

//MARK: - MAIN CONTENT
extension CapturedImages{
    
    var mainContent:some View{
        VStack{
            topButtons
            screenShotList
        }
    }
    
}

//MARK: - COREDATA-CARD
extension CapturedImages{
    
    var screenShotList:some View{
        ScrollViewCoreData(coreDataViewModel:coreDataViewModel){ screenShot in
                        screenShotCard(screenShot as? ScreenshotModel)
        }
    }
    
    @ViewBuilder
    func screenShotCard(_ model:ScreenshotModel?) -> some View{
        if let model = model,
           let image = model.image,
           let imageData = image.data,
           let uiImage = UIImage(data: imageData){
             FlippedCard(image: Image(uiImage: uiImage),
                        label: model.label,
                        modelId: model.modelId,
                        labelText: model.name ?? "",
                        descriptionText: model.shortDesc ?? "",
                        dateText: model.date?.toISO8601String() ?? "")
                        { newComment in
                            PersistenceController.updateScreenshot(model,with: newComment)}
                        tapGestureAction: { tappedPoint in
                            if state == .BASE {
                                withAnimation{
                                    expandedImageValues = ExpandedImageValues(
                                                            selectedImage: Image(uiImage: uiImage), startPosition: tappedPoint,
                                                                startValues: CGSize(),
                                                                endValues: CGSize())
                                }
                           }
                            else{
                                toggleListId(modelId:model.objectID,
                                             imageId:image.objectID)
                            }
                        }
             .overlay{
                cardIsSelected(model.objectID)
                .onTapGesture {
                    toggleListId(modelId:model.objectID,
                                 imageId:image.objectID)
                }
            }
       }
        
     }
    
    @ViewBuilder
    func cardIsSelected(_ modelId:NSManagedObjectID?) -> some View{
        if onListContainsModelId(modelId){
            Color.white.opacity(0.1)
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
            .vTop()
            .hCenter()
            .overlay{
                checkmarkCircle()
            }
       }
    }
}

//MARK: - BUTTONS
extension CapturedImages{
  
    var libraryLabel:some View{
        Text("Bibliotek")
        .foregroundStyle(Color.white)
        .font(.headline)
        .bold()
        .hCenter()
     }
    
    var editButton:some View{
        Button(action: { updateStateWith(.EDIT)}){
            Text("Redigera")
            .foregroundStyle(Color.white)
            .font(.headline)
            .bold()
        }
        .disabled(!coreDataViewModel.hasItemsLoaded)
        .opacity(coreDataViewModel.hasItemsLoaded ? 1.0 : 0.0)
        .padding(.horizontal)
    }
    
    var cancelButton:some View{
        Button(action: resetStateAndClearDeletedModelsList){
            Text("Avbryt")
            .foregroundStyle(Color.white)
            .font(.headline)
            .bold()
            .hTrailing()
        }
    }
    
    var selectAllButton:some View{
        Button(action: selectAllItems ){
            Text("Välj alla")
            .foregroundStyle(Color.white)
            .font(.headline)
            .bold()
            .hLeading()
        }
    }
    
    var removeButton:some View{
        Button(action: deleteSelectedItems ){
            Text("Ta bort")
            .foregroundStyle(Color.red)
            .font(.headline)
            .bold()
            .hLeading()
        }
        .disabled(emptyDeleteList)
    }
    
    
    var baseTopBar:some View{
        VStack{
            HStack{
                BackButtonAction(action: navigateBack)
                libraryLabel
                editButton
            }
            SplitLine()
        }
    }
    
    var editTopBarButtons:some View{
        HStack{
            selectAllButton
            cancelButton
        }
        .padding(.horizontal)
    }
    
    var editTopBarSection:some View{
        VStack{
            Text("Alla bilder")
                .font(.title)
                .foregroundStyle(Color.white)
                .bold()
                .hLeading()
                .padding([.horizontal,.top])
            VStack(spacing:V_SPACING_REG){
                Text("\(deleteListCount) valda")
                    .font(.title2)
                    .foregroundStyle(Color.white)
                    .bold()
                    .hLeading()
                removeButton
            }
            .padding([.leading,.top])
            .padding(.horizontal)
            .opacity(emptyDeleteList ? 0.5 : 1.0)
            SplitLine(color:Color.lightGold)
        }
        .background{
            Color.section
        }
    }
    
    var editTopBar:some View{
        VStack{
            editTopBarButtons
            SplitLine()
            editTopBarSection
        }
    }
    
    @ViewBuilder
    func currentTopBarButtons() -> some View{
        switch state{
        case .BASE:
            baseTopBar
        case .EDIT:
            editTopBar
        }
    }
    
    var topButtons:some View{
        currentTopBarButtons()
        .padding(.top)
    }
}

//MARK: - FUNCTIONS INVOLVING DELETE OPERATIONS
extension CapturedImages{
    func selectAllItems(){
        let items = coreDataViewModel.items.compactMap({
            if let imageId = $0.image?.objectID{
                return CoreDataRemoveItem(modelId: $0.objectID,
                                          imageId: imageId)
            }
            return nil
        })
        deleteModels = items
    }
     
    func deleteSelectedItems(){
        PersistenceController.deleteMultipleItems(models: deleteModels){ modelResult,imageResult in
           resetListOfSavedTubes()
        }
     }
    
    func onListContainsModelId(_ modelId:NSManagedObjectID?) -> Bool{
        if let modelId = modelId,
           let _ = deleteModels.firstIndex(where: {$0.modelId == modelId}){
            return true
        }
        return false
    }
    
    func toggleListId(modelId:NSManagedObjectID?,imageId:NSManagedObjectID?){
        if let modelId = modelId,
           let imageId = imageId{
            if let index = deleteModels.firstIndex(where: {$0.modelId == modelId}){
                deleteModels.remove(at: index)
            }
            else{
                deleteModels.append(CoreDataRemoveItem(modelId: modelId,
                                                       imageId: imageId))
            }
        }
    }
}

//MARK: - FUNCTIONS
extension CapturedImages{
    
    var emptyDeleteList:Bool{
        deleteModels.count == 0
    }
    
    var deleteListCount:Int{
        deleteModels.count
    }
    
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
    func resetListOfSavedTubes(){
        resetStateAndClearDeletedModelsList()
        coreDataViewModel.requestInitialSetOfItems()
    }
    
    func resetStateAndClearDeletedModelsList(){
        updateStateWith(.BASE)
        deleteModels.removeAll()
    }
     
    func updateStateWith(_ newState:LibraryState){
        withAnimation{
            state = newState
        }
    }
}




