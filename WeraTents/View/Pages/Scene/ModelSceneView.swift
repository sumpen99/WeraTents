//
//  ModelSceneView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-01.
//

import SwiftUI

enum ModelSceneHeader:String{
    case MODEL_3D       = "3D Model"
    case MODEL_PICTURES = "Bilder"
}

struct ModelHelper{
    var header:ModelSceneHeader = .MODEL_3D
    var toggleDimensionBox:Bool = false
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
        backgroundContent
        .sheet(isPresented: $helper.presentSheet) { sheetTentInfo }
        .ignoresSafeArea()
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            mainContent
        }
    }
}

//MARK: - MAIN CONTENT
extension ModelSceneView{
    var backgroundContent:some View{
        ZStack{
            Color.background
            bottomContainer
        }
        
    }
    
    var mainContent:some View{
        VStack(spacing:0){
            topContainer
            currentShownHeader()
        }
        .task{
            loadImages()
        }
        .padding(.vertical)
    }
     
}

//MARK: - CONTENT CONTAINER
extension ModelSceneView{
    @ViewBuilder
    func currentShownHeader() ->some View{
        GeometryReader{ reader in
            ZStack{
                if helper.header == .MODEL_3D{
                    SceneViewContainer(sceneViewCoordinator: sceneViewCoordinator)
                }
                else{
                    imageContainer(reader.min())
                }
            }
            .transition(.move(edge: .leading))
        }
    }
        
    func imageContainer(_ size:CGFloat) -> some View{
        VStack{
            ZoomableImage(uiImage: helper.currentSelectedImage(),size:size)
            optionalImages
        }
        .padding()
     }
  
    var optionalImages:some View{
        HStack{
            ForEach(Array(zip(helper.iconImages.indices, helper.iconImages)), id: \.0){ (index,uiImage) in
                Image(uiImage: uiImage)
                .resizable()
                .frame(width:50,height: 50)
                .padding(2)
                .background{
                    Rectangle().fill(helper.selectedImageIndex == index ? Color.white : Color.gray)
                }
                .onTapGesture {
                    withAnimation{
                        helper.selectedImageIndex = index
                    }
                }
            }
         }
        .hLeading()
    }
}

//MARK: - TOPBAR
extension ModelSceneView{
    var topContainer:some View{
        VStack{
            topButtons
            splitLine()
            tentBarContainerButtons
        }
        .hLeading()
        .padding(.horizontal)
    }
    
    var topButtons:some View{
        HStack{
            BackButtonAction(action: navigateBack)
            selectedTentLabel
            openInformationButton
        }
        .hLeading()
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
    
    var selectedTentLabel:some View{
        Text(selectedTent.name)
        .foregroundStyle(Color.white)
        .font(.body)
        .bold()
        .hCenter()
     }
}

//MARK: - MODEL-SELECTION
extension ModelSceneView{
   
    var tentBarContainerButtons:some View{
        HStack{
            labelHeaderCell(.MODEL_3D)
            labelHeaderCell(.MODEL_PICTURES)
        }
        .background{
            Color.materialDark
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
        .hLeading()
    }
    
    func labelHeaderCell(_ header:ModelSceneHeader) -> some View{
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
            }
        }
    }
}

//MARK: - BOTTOM SHEET
extension ModelSceneView{
    var bottomContainer:some View{
        ZStack{
            Color.white
            Indicator(minDistance: 10.0,cornerRadius: 0,indicatorColor:Color.black){
                helper.presentSheet.toggle()
            }
        }
        .frame(height: SHEET_MENU_HEIGHT)
        .hCenter()
        .vBottom()
    }
    
    var sheetTentInfo:some View{
        ZStack{
            Color.white
            Text("Detail")
        }
        .presentationDragIndicator(.visible)
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
