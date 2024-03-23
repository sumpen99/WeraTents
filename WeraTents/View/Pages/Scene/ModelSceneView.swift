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
    case USDZ_RESOURCE
}

enum HeaderSelection:String{
    case BRAND = "Märke"
    case MANUFACTURER = "Tillverkare"
    case ARTICLE_NUMBER = "Artikelnummer"
    
    static var all: [HeaderSelection]{
        return [.BRAND,.MANUFACTURER,.ARTICLE_NUMBER]
    }
}

struct ModelHelper{
    let buttons:[ButtonSelection] = ButtonSelection.all
    let headers:[HeaderSelection] = HeaderSelection.all
    var buttonSelection:ButtonSelection? = .DESCRIPTION
    var header:ModelDimensionHeader = .GRID_ON
    var toggleDimensionBox:Bool = true
    var presentSheet:Bool = false
    var selectedButtonIndex:Int = 0
    var showTentLabel:Bool = true
    var showBottomContainer:Bool = false
    var hasNotFetchedData:Bool = true
    var automaticFold:String? = "No"
    var selectedIconImageUrl:String?
    
}

struct ModelSceneView: View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @StateObject private var sceneViewCoordinator: SceneViewCoordinator
    @Namespace var animation
    @State var helper:ModelHelper = ModelHelper()
    let selectedTent:Tent
    init(selectedTent:Tent) {
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
                loadUSDZModel(){ firestoreViewModel.updateLoadingStateWith(state:.USDZ_MODEL,value: false) }
                helper.hasNotFetchedData = false
                helper.selectedIconImageUrl = selectedTent.iconStorageIds?.first
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
        VStack{
            HStack{
                BackButtonAction(action: navigateBack).hLeading()
                Text("Model")
                .font(.headline)
                .hCenter()
                .bold()
                .foregroundStyle(Color.white)
                openInformationButton.hTrailing()
            }
            SplitLine()
        }
        .padding(.vertical)
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
                    .matchedGeometryEffect(id: "CURRENT_SCENE_ HEADER", in: animation)
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
            webPageButton
        },label: {
            Image(systemName: "ellipsis.circle")
            .font(TOP_BAR_FONT)
            .bold()
            .foregroundStyle(Color.white)
        })
        .padding(.horizontal)
      }
    
    
}

//MARK: - POPUP MENU BUTTONS
extension ModelSceneView{
    var webPageButton: some View{
        UrlLabelButton(label: "Hemsida",
                       image: "network",
                       toVisit: selectedTent.webpage)
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
                          backgroundColor: Color.lightBrown,
                          indicatorColor:Color.black.opacity(0.3)){
                    helper.presentSheet.toggle()
                }
                selectedTentLabel
            }
            .background{
                Color.lightBrown
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
        .font(.title3)
        .bold()
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
                   FirestoreImage(iconImageUrl:helper.selectedIconImageUrl,
                                  imageType: .RESIZABLE_ONLY)
                   .frame(height: size)
                   optionalImages(width: size, size: 60.0)
                   VStack{
                       tentFoldableSection
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
        LazyVGrid(columns:numberOfColumns(maxWidth: width, size: size),
                   spacing: V_SPACING_REG,
                   pinnedViews: [.sectionHeaders]){
                    if let iconStorageImages = selectedTent.iconStorageIds{
                        ForEach(iconStorageImages, id: \.self){ iconImageUrl in
                            FirestoreImage(iconImageUrl:iconImageUrl,
                                           imageType: .RESIZABLE_ONLY)
                            .frame(width:size,height: size)
                            .padding(2)
                            .background{
                                Rectangle().fill(helper.selectedIconImageUrl == iconImageUrl ? Color.lightGold : Color.white)
                            }
                           .onTapGesture {
                                withAnimation{
                                    helper.selectedIconImageUrl = iconImageUrl
                                }
                            }
                        }
                     }
            }
            .padding(.horizontal)
    }
        
    @ViewBuilder
    var tentFoldableSection:some View{
        VStack(spacing:V_SPACING_REG){
            tentLabelSection
            foldableSection(headerText: "Pris",
                            contentText: selectedTent.price)
            foldableSection(headerText: "Produktvikt",
                            contentText: selectedTent.productWeight ?? "")
            dimensionContent
        }
    }
    
    var tentLabelSection:some View{
        SectionFoldableHeavy(header: selectedTentLabel,
                             content:headerSection,
                             splitColor: Color.lightGold.opacity(0.2),
                             toggleColor:Color.lightGold,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             automaticFold: $helper.automaticFold,
                             showContent: false,
                             addedSplitLine: true)
    }
    
    func foldableSection(headerText:String,contentText:String) -> some View{
        SectionFoldableHeavy(header: Text(headerText).bold(),
                             content: HeaderContent(content:Text(contentText).hLeading()),
                             splitColor: Color.lightGold.opacity(0.2),
                             toggleColor:Color.lightGold,
                             onLabelText: "Dölj",
                             offLabelText: "Visa",
                             automaticFold: $helper.automaticFold,
                             showContent: false,
                             addedSplitLine: true)
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
                case .BRAND: headerValue(header.rawValue, value: selectedTent.label)
                case .MANUFACTURER: headerValue(header.rawValue, value: selectedTent.manufacturer)
                case .ARTICLE_NUMBER: headerValue(header.rawValue, value: selectedTent.articleNumber)
                }
            }
        })
    }
    
    @ViewBuilder
    func headerValue(_ header:String,value:String?) ->some View{
        if let value = value{
            HStack{
                Text(header).font(.body).hLeading()
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
    
    @ViewBuilder
    var dimensionContent:some View{
        if let dimensions = selectedTent.dimensions{
            foldableSection(headerText: "Storlek",
                            contentText: dimensions.sizeDesc)
            foldableSection(headerText: "Monteringshöjd",
                            contentText: dimensions.heightDesc)
            if let infotext = dimensions.infoText{
                foldableSection(headerText: "Information",
                                contentText: infotext)
            }
        }
    }
   
}

//MARK: - FUNCTIONS
extension ModelSceneView{
   
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
        case .USDZ_RESOURCE:
            if let modelStorageIds = selectedTent.modelStorageIds{
                return modelStorageIds.count > 0 ? modelStorageIds : nil
            }
        }
        return nil
    }
    
    func numberOfColumns(maxWidth:CGFloat,size:CGFloat) -> [GridItem]{
        let itemCount = selectedTent.iconStorageIds?.count ?? 0 + 1
        let padding = CGFloat(itemCount)*V_SPACING_REG
        let count = max(0.0,floor((maxWidth-padding)/size))
        return Array.init(repeating: GridItem(), count: Int(count))
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
