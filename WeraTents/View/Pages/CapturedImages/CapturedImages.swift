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

struct CapturedImages:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @StateObject var coreDataViewModel:CoreDataViewModel
    @State var state:LibraryState = .BASE
    @State var deleteModelsId:[NSManagedObjectID] = []
        
    
    init() {
        self._coreDataViewModel = StateObject(wrappedValue: CoreDataViewModel())
    }
    
    var body: some View {
        background
        .toolbar(.hidden)
        .ignoresSafeArea()
        .safeAreaInset(edge: .top){
            content
         }
    }
}

//MARK: - MAIN CONTENT
extension CapturedImages{
    var background:some View{
        Color.background
        .vCenter()
        .hCenter()
        
    }
    
    var content:some View{
        VStack{
            topButtons
            itemsLoadedPage
        }
     }
}

//MARK: - COREDATA-LIST
extension CapturedImages{
    
    var itemsLoadedPage:some View{
        savedScreenshotList
        .padding([.leading,.trailing])
        .task{
            coreDataViewModel.setChildViewDimension(CHILD_VIEW_HEIGHT)
            coreDataViewModel.requestInitialSetOfItems()
        }
        .onDisappear{
            coreDataViewModel.clearAllData()
            clearAllData()
        }
    }
    
    var savedScreenshotList:some View{
        ScrollViewCoreData(coreDataViewModel:coreDataViewModel){ screenShot in
            screenShotCard(screenShot as? ScreenshotModel)
        }
    }
      
}

//MARK: - COREDATA-CARD
extension CapturedImages{
    
    @ViewBuilder
    func screenShotCard(_ item:ScreenshotModel?) -> some View{
        if let item = item,
           let image = item.image,
           let imageData = image.data,
           let uiImage = UIImage(data: imageData){
            FlippedCard(image: Image(uiImage: uiImage),
                        label: item.label,
                        modelId: item.modelId,
                        labelText: item.name ?? "",
                        descriptionText: item.shortDesc ?? "",
                        dateText: item.date?.toISO8601String() ?? "",
                        height: HOME_CAPTURED_HEIGHT,
                        ignoreTapGesture: true)
            .onTapGesture {
                if state == .BASE{
                    return
                }
                toggleListId(item.objectID)
                toggleListId(image.objectID)
            }
            .overlay{
                cardIsSelected(item.objectID)
            }
       }
        
     }
    
    @ViewBuilder
    func cardIsSelected(_ id:NSManagedObjectID?) -> some View{
        if onListContainsId(id){
            checkmarkCircle()
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
        Button(action: {
            withAnimation{
                state = .EDIT
            }
        }){
            Text("Redigera")
            .foregroundStyle(Color.lightBlue)
            .font(.headline)
            .bold()
        }
        .disabled(!coreDataViewModel.hasItemsLoaded)
        .opacity(coreDataViewModel.hasItemsLoaded ? 1.0 : 0.0)
        .padding(.horizontal)
    }
    
    var cancelButton:some View{
        Button(action: {
            withAnimation{
                reset()
            }
        }){
            Text("Avbryt")
            .foregroundStyle(Color.lightBlue)
            .font(.headline)
            .bold()
            .hTrailing()
        }
    }
    
    var selectAllButton:some View{
        Button(action: selectAllItems ){
            Text("Välj alla")
            .foregroundStyle(Color.lightBlue)
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
        VStack(spacing:0){
            Text("Alla filer")
                .font(.title)
                .foregroundStyle(Color.white)
                .bold()
                .hLeading()
            VStack(spacing:V_SPACING_REG){
                Text("\(listCount) valda")
                    .font(.title2)
                    .foregroundStyle(Color.white)
                    .bold()
                    .hLeading()
                removeButton
            }
            .padding([.leading,.top])
            .opacity(emptyDeleteList ? 0.5 : 1.0)
        }
        .padding()
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
            .padding(.vertical)
    }
}

//MARK: - FUNCTIONS
extension CapturedImages{
    
    var emptyDeleteList:Bool{
        deleteModelsId.count == 0
    }
    
    var listCount:Int{
        deleteModelsId.count
    }
    
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
    func selectAllItems(){
        if let items = coreDataViewModel.items?.compactMap({$0.objectID}){
            deleteModelsId.removeAll()
            deleteModelsId.append(contentsOf: items)
        }
    }
     
    func deleteSelectedItems(){
        DispatchQueue.global().async {
           PersistenceController.deleteMultipleItems(modelIds: deleteModelsId)
           resetListOfSavedTubes()
        }
     }
    
    func resetListOfSavedTubes(){
        DispatchQueue.main.async{
            clearListOfIds()
            coreDataViewModel.requestInitialSetOfItems()
            updateState()
        }
    }
    
    func onListContainsId(_ id:NSManagedObjectID?) ->Bool{
        if let id = id,
           let _ = deleteModelsId.firstIndex(of: id){
            return true
        }
        return false
    }
    
    func toggleListId(_ id:NSManagedObjectID?){
        if let id = id{
            if let index = deleteModelsId.firstIndex(of: id){
                deleteModelsId.remove(at: index)
            }
            else{
                deleteModelsId.append(id)
            }
        }
    }
    
    func reset(){
        state = .BASE
        deleteModelsId.removeAll()
    }
    
    func clearListOfIds(){
        deleteModelsId.removeAll()
    }
     
    func clearAllData(){
        deleteModelsId.removeAll()
    }
    
    func updateState(){
        state = emptyDeleteList ? .BASE : state
    }
    
}




