//
//  ModelSceneView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-01.
//

import SwiftUI

enum ModelDimensionHeader:String{
    case GRID_ON       = "Grid På"
    case GRID_OFF = "Grid Av"
}

struct ModelHelper{
    var header:ModelDimensionHeader = .GRID_ON
    var toggleDimensionBox:Bool = true
    var presentSheet:Bool = false
    var iconImages:[UIImage] = []
    var selectedImageIndex:Int = 0
    
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
            labelHeaderCell(.GRID_ON)
            labelHeaderCell(.GRID_OFF)
        }
        .background{
            Color.materialDark
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
   }
    
    func labelHeaderCell(_ header:ModelDimensionHeader) -> some View{
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
            Button(action: { } ){
                Label("Document", systemImage: "doc")
            }.padding()
            Button(action: { } ){
                Label("Document", systemImage: "doc")
            }.padding()
            Button(action: { } ){
                Label("Document", systemImage: "doc")
            }.padding()
            Button(action: { } ){
                Label("Document", systemImage: "doc")
            }.padding()
        },label: {
            buttonImage("ellipsis.circle",font: TOP_BAR_FONT,foreground: Color.white)
        })
      }
    
    
}

//MARK: - BOTTOM CONTAINER
extension ModelSceneView{
    var bottomContainer:some View{
        ZStack{
            Indicator(width:40,height:5.0,minDistance: 10.0,cornerRadius: 0,indicatorColor:Color(uiColor: .lightGray).opacity(0.8)){
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
        .font(.headline)
        .bold()
        .hCenter()
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
        .presentationDetents([.fraction(0.5), .large])
    }
    
    func sheetScrollContent(_ size:CGFloat) -> some View{
        ScrollView{
           VStack{
               ZoomableImage(uiImage: helper.currentSelectedImage(),size:size)
               optionalImages
               HStack{
                   VStack{
                       Text("Tillbehör").font(.headline).bold().hLeading()
                       ForEach(selectedTent.equipment ?? [],id:\.self){ equipment in
                           Text(String(BULLET + equipment)).font(.body).hLeading()
                       }
                   }
                    VStack{
                       Text("Information").font(.headline).bold().hLeading()
                       ForEach(selectedTent.bareInMind ?? [],id:\.self){ bareInMind in
                           Text(String(BULLET + bareInMind)).font(.body).hLeading()
                       }
                   }
               }
               VStack{
                   Text("Kategori").font(.headline).bold().hLeading()
                   Text(selectedTent.category ?? "").font(.body).hLeading()
               }
               VStack{
                   Text("Märke").font(.headline).bold().hLeading()
                   Text(selectedTent.label ?? "").font(.body).hLeading()
               }
               VStack{
                   Text("Information:").font(.headline).bold().hLeading()
                   Text(selectedTent.shortDescription).font(.body).hLeading()
               }
               VStack{
                   Text("Pris:").font(.headline).bold().hLeading()
                   Text(selectedTent.price ?? "").font(.body).hLeading()
               }
               VStack{
                   Text("Produktvikt:").font(.headline).bold().hLeading()
                   Text(selectedTent.productWeight ?? "").font(.body).hLeading()
               }
               VStack{
                   Text("Beskrivning:").font(.headline).bold().hLeading()
                   Text(selectedTent.longDescription ?? "").font(.body).hLeading()
               }
           }
        }
        .scrollIndicators(.hidden)
    }
   
    var optionalImages:some View{
        ScrollView(.horizontal){
            HStack{
                ForEach(Array(zip(helper.iconImages.indices, helper.iconImages)), id: \.0){ (index,uiImage) in
                    Image(uiImage: uiImage)
                    .resizable()
                    .frame(width:80,height: 80)
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
