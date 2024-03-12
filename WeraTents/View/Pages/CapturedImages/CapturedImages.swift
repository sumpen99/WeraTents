//
//  CapturedImages.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-28.
//

import SwiftUI

enum LibraryState{
    case BASE
    case EDIT
}


struct LibraryHelper{
    var state:LibraryState = .BASE
    var deleteModelsId:[String] = []
    var labelHeaderList:[String] = []
    var selectedScreenShotModel:ScreenshotModel? = nil
    var labelHeader:String?
        
    var emptyDeleteList:Bool{
        deleteModelsId.count == 0
    }
    
    var emptyLabelsList:Bool{
        labelHeaderList.count == 0
    }
    
    var listCount:Int{
        deleteModelsId.count
    }
    
    func onListContainsId(_ id:String?) ->Bool{
        if let id = id,
           let _ = deleteModelsId.firstIndex(of: id){
            return true
        }
        return false
    }
    
    mutating func updateState(){
        withAnimation{
            state = emptyLabelsList ? .BASE : state
        }
    }
    
    mutating func updateLabelsList(_ labels:[String]){
        labelHeaderList = labels
    }
    
    mutating func toggleListId(_ id:String?){
        if let id = id{
            if let index = deleteModelsId.firstIndex(of: id){
                deleteModelsId.remove(at: index)
            }
            else{
                deleteModelsId.append(id)
            }
        }
    }
    
    mutating func reset(){
        state = .BASE
        deleteModelsId.removeAll()
    }
    
    mutating func clearListOfIds(){
        deleteModelsId.removeAll()
    }
    
    mutating func clearListOfLabels(){
        labelHeaderList.removeAll()
    }
    
    mutating func clearSelectedItem(){
        withAnimation{
            selectedScreenShotModel = nil
            
        }
    }
    
    mutating func clearAllData(){
        labelHeaderList.removeAll()
        deleteModelsId.removeAll()
    }
}

struct CapturedImages:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @StateObject var coreDataViewModel:CoreDataViewModel
    @State var library:LibraryHelper = LibraryHelper()
    @Namespace var animation
   
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
        ZStack{
            Color.background
         }
        .vCenter()
        .hCenter()
        
    }
    
    var content:some View{
        VStack{
            topButtons
            itemsLoadedPage
       }
        .overlay{
            selectedCard.padding()
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
            setCurrentLabels()
        }
        .onDisappear{
            coreDataViewModel.clearAllData()
            library.clearAllData()
        }
    }
    
    var savedScreenshotList:some View{
        ScrollViewCoreData(coreDataViewModel:coreDataViewModel){ screenShot in
            screenShotCard(screenShot as? ScreenshotModel)
            .onTapGesture {
                withAnimation{
                    if let screenShotModel = screenShot as? ScreenshotModel,
                       let id = screenShotModel.id{
                        if library.state == .BASE{
                            library.selectedScreenShotModel = screenShotModel
                        }
                        else{
                            library.toggleListId(id)
                        }
                    }
                 }
            }
        }
    }
      
}

//MARK: - COREDATA-CARD
extension CapturedImages{
  
    @ViewBuilder
    func cardIsSelected(_ id:String?) -> some View{
        if library.onListContainsId(id){
            ZStack{
                Color.white.opacity(0.5)
                checkmarkCircle()
       
            }
            .vCenter()
            .hCenter()
       }
    }
    
    @ViewBuilder
    func screenShotCard(_ item:ScreenshotModel?) -> some View{
        ZStack{
#if targetEnvironment(simulator)
        Image("profile_black_white")
        .resizable()
        .scaledToFit()
#else
        if let item = item,
           let image = item.image,
           let data = image.data,
           let uiImage = UIImage(data: data){
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        }
#endif
        }
        .overlay{
            cardIsSelected(item?.id)
        }
     }
}

//MARK: - COREDATA SELECTED CARD
extension CapturedImages{
    @ViewBuilder
    var selectedCard:some View{
        if library.selectedScreenShotModel != nil{
            ZStack{
#if targetEnvironment(simulator)
                Color.white
                ScrollView{
                    VStack{
                        
                        Image("profile_black_white")
                            .resizable()
                            .scaledToFit()
                        Text(library.selectedScreenShotModel?.name ?? "")
                            .font(.title)
                            .bold()
                            .hLeading()
                        Text("Width: \(library.selectedScreenShotModel?.width ?? 0.0)")
                            .font(.body)
                            .bold()
                            .hLeading()
                        Text("Height: \(library.selectedScreenShotModel?.height ?? 0.0)")
                            .font(.body)
                            .bold()
                            .hLeading()
                        Text("Depth: \(library.selectedScreenShotModel?.depth ?? 0.0)")
                            .font(.body)
                            .bold()
                            .hLeading()
                    }
                    .hLeading()
                    .padding()
                }
           
#else
                if let item = library.selectedScreenShotModel,
                   let image = item.image,
                   let data = image.data,
                   let uiImage = UIImage(data: data){
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
        }
#endif
            }
             .transition(.opacity.combined(with: .scale))
            .onTapGesture {
                withAnimation{
                    library.clearSelectedItem()
                }
            }
        }
        
    }
    
}

//MARK: - SCROLL-LABEL-LIST
extension CapturedImages{
     
    var settingsItemMenuList:some View{
        ScrollView(.horizontal){
            LazyHStack(alignment: .center, spacing: 20, pinnedViews: [.sectionHeaders]){
                ForEach(library.labelHeaderList, id: \.self) { label in
                    labelHeaderCell(label)
               }
            }
            .padding()
        }
        .frame(height:MENU_HEIGHT)
        .scrollIndicators(.never)
    }
    
    func labelHeaderCell(_ label:String) -> some View{
        return Text(label)
        .font(.headline)
        .bold()
        .frame(height: 33)
        .foregroundStyle(label == library.labelHeader ? Color.white : Color.gray )
        .padding([.vertical],5)
        .padding([.horizontal],10)
        .background(
             ZStack{
                 if label == library.labelHeader{
                     RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL)
                         .stroke(style: .init(lineWidth: 2.0))
                         .foregroundStyle(Color.white)
                    .matchedGeometryEffect(id: "CURRENTHEADER", in: animation)
                 }
             }
        )
        .onTapGesture {
            withAnimation{
                library.labelHeader = label
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
        Button(action: {
            withAnimation{
                library.state = .EDIT
            }
        }){
            Text("Redigera")
            .foregroundStyle(Color.lightBlue)
            .font(.headline)
            .bold()
            .hTrailing()
        }
        .opacity(library.emptyLabelsList ? 0 : 1)
        .disabled(library.emptyLabelsList)
    }
    
    var cancelButton:some View{
        Button(action: {
            withAnimation{
                library.reset()
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
        .disabled(library.emptyDeleteList)
    }
    
    
    var baseTopBar:some View{
        VStack{
            HStack{
                BackButtonAction(action: navigateBack).hLeading()
                libraryLabel
                editButton
            }
            SplitLine()
            settingsItemMenuList
        }
        
    }
    
    var editTopBarButtons:some View{
        HStack{
            selectAllButton
            cancelButton
        }
    }
    
    var editTopBarSection:some View{
        VStack(spacing:0){
            Text("Alla filer")
                .font(.title)
                .foregroundStyle(Color.white)
                .bold()
                .hLeading()
            VStack(spacing:V_SPACING_REG){
                Text("\(library.listCount) valda")
                    .font(.title2)
                    .foregroundStyle(Color.white)
                    .bold()
                    .hLeading()
                removeButton
            }
            .padding([.leading,.top])
            .opacity(library.emptyDeleteList ? 0.5 : 1.0)
            
        }
        .padding(.top)
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
        switch library.state{
        case .BASE:
            baseTopBar
        case .EDIT:
            editTopBar
        }
    }
    
    var topButtons:some View{
        currentTopBarButtons()
        .animation(.linear(duration: 0.5),value: library.state)
        .transition(.opacity.combined(with: .scale))
        .matchedGeometryEffect(id: "CURRENTTOPMENY", in: animation)
        .padding()
    }
}

//MARK: - FUNCTIONS
extension CapturedImages{
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
    func selectAllItems(){
        if let items = coreDataViewModel.items?.compactMap({$0.id ?? ""}){
            library.deleteModelsId.removeAll()
            library.deleteModelsId.append(contentsOf: items)
        }
    }
     
    func deleteSelectedItems(){
        DispatchQueue.global().async {
            for modelId in library.deleteModelsId{
                if let model = coreDataViewModel.getModelById(modelId){
                    PersistenceController.deleteScreenshotImage(model.image)
                    PersistenceController.deleteScreenshotModel(model)
                }
            }
            resetListOfSavedTubes()
        }
     }
    
    func resetListOfSavedTubes(){
        DispatchQueue.main.async{
            library.clearListOfIds()
            library.clearListOfLabels()
            coreDataViewModel.requestInitialSetOfItems()
            setCurrentLabels()
        }
    }
    
    func setCurrentLabels(){
        coreDataViewModel.requestAllUniqueLabels(){ labels in
            library.updateLabelsList(labels)
            library.updateState()
        }
    }
     
}




