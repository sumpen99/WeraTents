//
//  ModelSceneView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-01.
//

import SwiftUI

enum ModelDimensionHeader:String{
    case GRID_ON        = "Grid På"
    case GRID_OFF       = "Grid Av"
}

enum ButtonSelection:String{
    case DESCRIPTION = "Beskrivning"
    case EQUIPMENT = "Medföljande utrustning"
    case BARE_IN_MIND = "Tänk på att"
}

enum HeaderSelection:String{
    case PRICE = "Pris"
    case BRAND = "Märke"
    case MANUFACTURER = "Tillverkare"
    case PRODUCT_WEIGHT = "Produktvikt"
    case ARTICLE_NUMBER = "Artikelnummer"
}

struct ModelHelper{
    let buttons:[ButtonSelection] = [.DESCRIPTION,.EQUIPMENT,.BARE_IN_MIND]
    let headers:[HeaderSelection] = [.PRICE,.BRAND,.MANUFACTURER,.PRODUCT_WEIGHT,.ARTICLE_NUMBER]
    var buttonSelection:ButtonSelection? = .DESCRIPTION
    var header:ModelDimensionHeader = .GRID_ON
    var toggleDimensionBox:Bool = true
    var presentSheet:Bool = false
    var iconImages:[UIImage] = []
    var selectedImageIndex:Int = 0
    var selectedButtonIndex:Int = 0
    var showTentLabel:Bool = true
    
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
            Color.black
            SceneViewContainer(sceneViewCoordinator: sceneViewCoordinator)
            bottomContainer
        }
        .ignoresSafeArea(.all)
        .task{
             loadImages()
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
            UrlLabelButton(label: "Se mer på hemsidan",
                           image: "network", 
                           toVisit: selectedTent.webpage)
            Button(action: { } ){
                Label("Instruktionsfilmer", systemImage: "play.tv")
            }.padding()
          
        },label: {
            buttonImage("info.circle",font: TOP_BAR_FONT,foreground: Color.white)
        })
      }
    
    
}

//MARK: - BOTTOM CONTAINER
extension ModelSceneView{
    var bottomContainer:some View{
        ZStack{
            Indicator(width:40,
                      height:5.0,
                      minDistance: 10.0,
                      cornerRadius: 0,
                      backgroundColor: Color.white,
                      indicatorColor:Color(uiColor: .lightGray).opacity(0.8)){
                helper.presentSheet.toggle()
            }
            selectedTentLabel
        }
        .background{
            Color.white
        }
        .frame(height: helper.presentSheet ? 0.0 : MENU_HEIGHT)
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_SHEET))
        .hCenter()
        .vBottom()
    }
    
    var selectedTentLabel:some View{
        Text(selectedTent.name)
        .frame(height: TIP_OF_SHEET)
        .foregroundStyle(Color.materialDark)
        .font(.title3)
        .bold()
        .padding([.top,.bottom])
     }
    
    @ViewBuilder
    var selectedTentLabelAnimated:some View{
        if helper.showTentLabel {
            selectedTentLabel
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                    withAnimation{
                        helper.showTentLabel = false
                    }
                }
            }
           
        }
        
     }
    
}

//MARK: - SHEET CONTAINER
extension ModelSceneView{
    var sheetTentInfo:some View{
        GeometryReader{ reader in
            sheetScrollContent(reader.min())
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.fraction(0.5), .large])
        .onDisappear{
            withAnimation{
                helper.showTentLabel = true
            }
        }
    }
    
    func sheetScrollContent(_ size:CGFloat) -> some View{
        ScrollView{
           VStack{
               selectedTentLabelAnimated
               ZoomableImage(uiImage: helper.currentSelectedImage(),size:size)
               optionalImages(size:max(50,size/5))
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
   
    func optionalImages(size:CGFloat) -> some View{
        LazyVGrid(columns:[GridItem(),GridItem(),GridItem(),GridItem()],
                   spacing: 10,
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
                HeaderContent(content: 
                    Text(selectedTent.longDescription ?? "").font(.body).hLeading()
                )
            case .EQUIPMENT:
                HeaderContent(content:
                    VStack(spacing:V_SPACING_REG){
                        ForEach(selectedTent.equipment ?? [],id:\.self){ equipment in
                            Text(String(BULLET + equipment)).font(.body).hLeading()
                        }
                    }
                )
            case .BARE_IN_MIND:
                HeaderContent(content:
                        VStack(spacing:V_SPACING_REG){
                        if let bareInMind = selectedTent.bareInMind{
                            ForEach(Array(zip(bareInMind.indices,bareInMind)),id:\.0){ (index,value) in
                                if index == 0{
                                    Text(value).font(.headline).bold().hLeading()
                                }
                                else{
                                    Text(String(BULLET + value)).font(.body).hLeading()
                                }
                            }
                        }
                    }
                )
            }
        }
        
    }
   
}

//MARK: - FUNCTIONS
extension ModelSceneView{
    
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
    
    func navigateBack(){
        sceneViewCoordinator.destroy()
        navigationViewModel.popPath()
     }
    
    func toggleBorder(){
        sceneViewCoordinator.toggleDimensionBox()
    }
    
}
