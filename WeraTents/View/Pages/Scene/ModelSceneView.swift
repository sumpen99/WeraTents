//
//  ModelSceneView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-01.
//

import SwiftUI

enum ModelDimensionHeader:String{
    case GRID_ON        = "Dimensioner På"
    case GRID_OFF       = "Av"
}

enum ButtonSelection:String{
    case DESCRIPTION = "Beskrivning"
    case EQUIPMENT = "Medföljande utrustning"
    case BARE_IN_MIND = "Tänk på att"
    
    static var all: [ButtonSelection]{
        return [.DESCRIPTION,.EQUIPMENT,.BARE_IN_MIND]
    }
}

enum ArrayToCheck{
    case EQUIPMENT
    case BARE_IN_MIND
    case VIDEO_RESOURCE
    case PDF_RESOURCE
    case USDZ_RESOURCE
}

enum HeaderSelection:String{
    case PRICE = "Pris"
    case BRAND = "Märke"
    case MANUFACTURER = "Tillverkare"
    case PRODUCT_WEIGHT = "Produktvikt"
    case ARTICLE_NUMBER = "Artikelnummer"
    
    static var all: [HeaderSelection]{
        return [.PRICE,.BRAND,.MANUFACTURER,.PRODUCT_WEIGHT,.ARTICLE_NUMBER]
    }
}

struct ModelHelper{
    let buttons:[ButtonSelection] = ButtonSelection.all
    let headers:[HeaderSelection] = HeaderSelection.all
    var buttonSelection:ButtonSelection? = .DESCRIPTION
    var header:ModelDimensionHeader = .GRID_ON
    var toggleDimensionBox:Bool = true
    var presentSheet:Bool = false
    var iconImages:[UIImage] = []
    var selectedImageIndex:Int = 0
    var selectedButtonIndex:Int = 0
    var showTentLabel:Bool = true
    var showBottomContainer:Bool = false
    var hasNotFetchedData:Bool = true
    
    func currentSelectedImage() -> UIImage?{
        if 0 < iconImages.count && selectedImageIndex < iconImages.count{
            return iconImages[selectedImageIndex]
        }
        return nil
    }
}

struct ModelSceneView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @StateObject private var sceneViewCoordinator: SceneViewCoordinator
    @Namespace var animation
    @State var helper:ModelHelper = ModelHelper()
    let selectedTent:TentItem
    init(selectedTent:TentItem) {
        self._sceneViewCoordinator = StateObject(wrappedValue: SceneViewCoordinator())
        self.selectedTent = selectedTent
    }
            
    var body: some View{
        mainContent
        .sheet(isPresented: $helper.presentSheet) { sheetTentInfo }
        .ignoresSafeArea(.all)
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            topContainer
        }
    }
}

//MARK: - MAIN CONTENT
extension ModelSceneView{
    var mainContent:some View{
        ZStack{
            Color.background
            sceneviewContent
            bottomContainer
        }
        .ignoresSafeArea(.all)
        .task{
            if helper.hasNotFetchedData{
                firestoreViewModel.updateLoadingStateWith(state:.USDZ_MODEL,value: true)
                loadImages()
                loadUSDZModel(){ firestoreViewModel.updateLoadingStateWith(state:.USDZ_MODEL,value: false) }
                helper.hasNotFetchedData = false
            }
            animateBottenContainerWith(value:true)
        }
    }
    
    var sceneviewContent:some View{
        SceneViewContainer(sceneViewCoordinator: sceneViewCoordinator)
        .overlay{
            if firestoreViewModel.loadingState(.USDZ_MODEL){
                SpinnerAnimation()
            }
        }
    }
        
}

//MARK: - TOPCONTAINER
extension ModelSceneView{
    var topContainer:some View{
        HStack{
            BackButtonAction(action: navigateBack)
            toggleGridButtons.hCenter()
            openInformationButton
        }
        .padding([.top,.horizontal])
   }
    
    var toggleGridButtons:some View{
        HStack{
            gridHeaderCell(.GRID_ON)
            gridHeaderCell(.GRID_OFF)
        }
        .background{
            Color.materialDark
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
   }
    
    func gridHeaderCell(_ header:ModelDimensionHeader) -> some View{
        return Text(header.rawValue)
        .font(.headline)
        .bold()
        .frame(height: 33)
        .foregroundStyle(header == helper.header ? Color.background : Color.materialDarkest )
        .padding([.vertical],5)
        .padding([.horizontal],10)
        .background(
             ZStack{
                 if header == helper.header{
                     RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL)
                    .fill(Color.white)
                    .matchedGeometryEffect(id: "CURRENTSCENEHEADER", in: animation)
                 }
             }
        )
       .onTapGesture {
            withAnimation{
                helper.header = header
                sceneViewCoordinator.toggleDimensionBox()
            }
        }
    }
    
    var openInformationButton:some View{
        Menu(content:{
            youtubeButton
            pdfButton
            webPageButton
        },label: {
            buttonImage("ellipsis.circle",font: TOP_BAR_FONT,foreground: Color.white)
        })
      }
    
    
}

//MARK: - POPUP MENU BUTTONS
extension ModelSceneView{
    var webPageButton: some View{
        UrlLabelButton(label: "Hemsida",
                       image: "network",
                       toVisit: selectedTent.webpage)
    }
    
    var youtubeButton: some View{
        Button(action: navigateToMovies ){
            Label("Instruktionsfilmer", systemImage: "play.tv")
        }
        .disabled(disabledVideoButton)
        .padding()
    }
    
    var pdfButton: some View{
        Button(action: navigateToPdf ){
            Label("Instruktionsmanual", systemImage: "book.pages")
        }
        .disabled(disabledPdfButton)
        .padding()
    }
}

//MARK: - BOTTOM CONTAINER
extension ModelSceneView{
    @ViewBuilder
    var bottomContainer:some View{
        if helper.showBottomContainer{
            ZStack{
                Indicator(width:40,
                          height:5.0,
                          minDistance: 10.0,
                          cornerRadius: 0,
                          backgroundColor: Color.lightGold,
                          indicatorColor:Color.white.opacity(0.3)){
                    helper.presentSheet.toggle()
                }
                selectedTentLabel
            }
            .background{
                Color.lightGold
            }
            .frame(height: helper.presentSheet ? 0.0 : MENU_HEIGHT)
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_SHEET))
            .hCenter()
            .vBottom()
            .animation(.linear(duration: 0.25),value: helper.presentSheet)
            .transition(.move(edge: .bottom))
        }
        
    }
    
    var selectedTentLabel:some View{
        Text(selectedTent.name)
        .frame(height: TIP_OF_SHEET)
        .foregroundStyle(Color.materialDark)
        .font(.title3)
        .bold()
        .italic()
        .padding([.top,.bottom])
     }
}

//MARK: - SHEET CONTAINER
extension ModelSceneView{
    var sheetTentInfo:some View{
        GeometryReader{ reader in
            sheetScrollContent(reader.min())
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
   
    }
    
    @ViewBuilder
    func sheetScrollContent(_ size:CGFloat) -> some View{
        if size != 0{
            ScrollView{
               VStack{
                   ZoomableImage(uiImage: helper.currentSelectedImage(),size:size)
                   optionalImages(width: size, size: 60.0)
                   VStack{
                       tentLabelSection
                       buttonSection(size)
                       buttonValue
                   }
                   .padding()
               }
            }
            .scrollIndicators(.hidden)
        }
        
    }
   
    @ViewBuilder
    func optionalImages(width:CGFloat,size:CGFloat) -> some View{
        if helper.iconImages.count > 0{
            LazyVGrid(columns:numberOfColumns(maxWidth: width, size: size),
                       spacing: V_SPACING_REG,
                       pinnedViews: [.sectionHeaders]){
                ForEach(Array(zip(helper.iconImages.indices, helper.iconImages)), id: \.0){ (index,uiImage) in
                    Image(uiImage: uiImage)
                    .resizable()
                    .frame(width:size,height: size)
                    .padding(2)
                    .background{
                        Rectangle().fill(helper.selectedImageIndex == index ? Color.lightGold : Color.white)
                    }
                   .onTapGesture {
                        withAnimation{
                            helper.selectedImageIndex = index
                        }
                    }
                }
             }
            .padding(.horizontal)
        }
        
    }
    
    var tentLabelSection:some View{
        SectionFoldableHeavy(header: selectedTentLabel,
                             content:headerSection,
                             backgroundColor: Color.lightGold.opacity(0.2))
        .hLeading()
    }
    
    func buttonSection(_ size:CGFloat) -> some View{
        HStack{
            ForEach(helper.buttons,id:\.self){ label in
                ExpandableButton(buttonSelection:$helper.buttonSelection,label:label,width:size/3.5){
                    withAnimation{
                        helper.buttonSelection = helper.buttonSelection == label ? nil : label
                    }
                }
            }
        }
        .padding(.top)
    }
   
    var headerSection:some View{
        HeaderContent(content: VStack{
            ForEach(helper.headers,id:\.self){ header in
                switch header{
                case .PRICE: headerValue(header.rawValue, value: selectedTent.price)
                case .BRAND: headerValue(header.rawValue, value: selectedTent.label)
                case .MANUFACTURER: headerValue(header.rawValue, value: selectedTent.manufacturer)
                case .PRODUCT_WEIGHT: headerValue(header.rawValue, value: selectedTent.productWeight)
                case .ARTICLE_NUMBER: headerValue(header.rawValue, value: selectedTent.articleNumber)
                }
            }
        })
    }
    
    @ViewBuilder
    func headerValue(_ header:String,value:String?) ->some View{
        if let value = value{
            HStack{
                Text(header).font(.body).bold().hLeading()
                Text(value).font(.callout).hLeading()
            }
        }
        
    }
    
    @ViewBuilder
    var buttonValue:some View{
        if let buttonSelection = helper.buttonSelection{
            switch buttonSelection{
            case .DESCRIPTION:
                descriptionContent
            case .EQUIPMENT:
                equipmentContent
            case .BARE_IN_MIND:
                bareInMindContent
            }
        }
        
    }
    
    @ViewBuilder
    var descriptionContent:some View{
        if let longDescription = selectedTent.longDescription{
            HeaderContent(content:
                Text(longDescription).font(.body).hLeading()
            )
        }
    }
    
    @ViewBuilder
    var equipmentContent:some View{
        if let equipment = checkArrayOf(type:.EQUIPMENT){
            HeaderContent(content:
                VStack(spacing:V_SPACING_REG){
                    ForEach(equipment,id:\.self){ equipment in
                        Text(String(BULLET + equipment)).font(.body).hLeading()
                    }
            })
        }
    }
    
    @ViewBuilder
    var bareInMindContent:some View{
        if let bareInMind = checkArrayOf(type:.BARE_IN_MIND){
            HeaderContent(content:
                VStack(spacing:V_SPACING_REG){
                     ForEach(Array(zip(bareInMind.indices,bareInMind)),id:\.0){ (index,value) in
                        if index == 0{ Text(value).font(.body).italic().hLeading() }
                        else{ Text(String(BULLET + value)).font(.body).hLeading() }
                     }
                })
        }
    }
   
}

//MARK: - FUNCTIONS
extension ModelSceneView{
    
    var disabledVideoButton:Bool{
        selectedTent.instructionVideoUrls?.count ?? 0 == 0
    }
    
    var disabledPdfButton:Bool{
        selectedTent.instructionPdfIds?.count ?? 0 == 0
    }
    
    func checkArrayOf(type:ArrayToCheck) ->[String]?{
        switch type {
        case .EQUIPMENT:
            if let equipment = selectedTent.equipment{
                return equipment.count > 0 ? equipment : nil
            }
        case .BARE_IN_MIND:
            if let bareInMind = selectedTent.bareInMind{
                return bareInMind.count > 0 ? bareInMind : nil
            }
        case .VIDEO_RESOURCE:
            if let instructionVideoUrls = selectedTent.instructionVideoUrls{
                return instructionVideoUrls.count > 0 ? instructionVideoUrls : nil
            }
        case .USDZ_RESOURCE:
            if let modelStorageIds = selectedTent.modelStorageIds{
                return modelStorageIds.count > 0 ? modelStorageIds : nil
            }
        case .PDF_RESOURCE:
            if let instructionPdfIds = selectedTent.instructionPdfIds{
                return instructionPdfIds.count > 0 ? instructionPdfIds : nil
            }
        }
        return nil
    }
    
    func numberOfColumns(maxWidth:CGFloat,size:CGFloat) -> [GridItem]{
        let itemCount = helper.iconImages.count + 1
        let padding = CGFloat(itemCount)*V_SPACING_REG
        let count = max(0.0,floor((maxWidth-padding)/size))
        return Array.init(repeating: GridItem(), count: Int(count))
    }
    
    func loadImages(){
        if let iconStorageIds = selectedTent.iconStorageIds{
            if FETCH_LOCALLY{
                firestoreViewModel.loadTentImagesFromLocal(iconStorageIds){ uiImages in
                    helper.iconImages = uiImages
                }
            }
            else{
                firestoreViewModel.loadTentImagesFromServer(iconStorageIds){ uiImage in
                    helper.iconImages.append(uiImage)
                }
            }
        }
    }
    
    func loadUSDZModel(onCompletion: @escaping () -> Void){
        if let usdzModels = checkArrayOf(type:.USDZ_RESOURCE),
           let modelId = usdzModels.first{
            firestoreViewModel.loadTentModelData(modelId){ url in
                sceneViewCoordinator.setSceneViewFromUrl(url)
                //ServiceManager.removeDataFromTemporary(url)
                onCompletion()
            }
         }
         else{ onCompletion() }
    }
    
    func navigateToMovies(){
        if let instructionVideoUrls = checkArrayOf(type:.VIDEO_RESOURCE){
            var listOfVideoItems:[VideoItem] = []
            for videoUrl in instructionVideoUrls{
                listOfVideoItems.append(VideoItem(id: shortId(),
                                                  videoUrl: videoUrl,
                                                  title: ""))
            }
            navigationViewModel.appendToPathWith(VideoResourcesItem(id: shortId(),
                                                                    listOfVideoItems: listOfVideoItems))
        }
    }
    
    func navigateToPdf(){
        if let instructionPdfIds = checkArrayOf(type:.PDF_RESOURCE){
            var listOfPdfItems:[PdfItem] = []
            for pdfId in instructionPdfIds{
                listOfPdfItems.append(PdfItem(id: shortId(),
                                                  pdfId: pdfId,
                                                  title: ""))
            }
            navigationViewModel.appendToPathWith(PdfResourcesItem(id: shortId(),
                                                                  listOfPdfItems: listOfPdfItems))
        }
    }
    
    func navigateBack(){
        sceneViewCoordinator.destroy()
        navigationViewModel.popPath()
     }
    
    func toggleBorder(){
        sceneViewCoordinator.toggleDimensionBox()
    }
    
    func animateBottenContainerWith(value:Bool){
        withAnimation{
            helper.showBottomContainer = true
        }
    }
    
}
