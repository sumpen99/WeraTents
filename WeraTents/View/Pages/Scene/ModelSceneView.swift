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
    var overlayImage:Bool = false
    
    mutating func toggleOverlayImage(){
        withAnimation{
            overlayImage.toggle()
        }
    }
}

struct ModelSceneView: View {
    @StateObject private var sceneViewCoordinator: SceneViewCoordinator
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Namespace var animation
    @State var helper:ModelHelper = ModelHelper()
    let selectedTent:TentItem
    init(selectedTent:TentItem) {
        self._sceneViewCoordinator = StateObject(wrappedValue: SceneViewCoordinator())
        self.selectedTent = selectedTent
    }
            
    var body: some View{
        backgroundContent
        .ignoresSafeArea()
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            mainContent
        }
        .overlay{
            if helper.overlayImage{
                //imageUpScaled
            }
        }
     
    }
}


//MARK: - MAIN CONTENT
extension ModelSceneView{
    var backgroundContent:some View{
        ZStack{
            Color.background
        }
        
    }
    
    var mainContent:some View{
        ZStack{
            VStack{
                topContainer
                currentShownHeader()
            }
        }
        .padding(.vertical)
    }
    
    var imageUpScaled:some View{
        ZStack{
            Color.white
            selectedTent.img
            .resizable()
        }
        .vCenter()
        .hCenter()
        .transition(.opacity.combined(with: .scale))
        .onTapGesture {
            withAnimation{
                helper.overlayImage.toggle()
            }
       }
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
            optionalImages
            currentImage(size)
        }
        .padding(.horizontal)
    }
    
    func currentImage(_ size:CGFloat) -> some View{
        ZStack{
            selectedTent.img
            .resizable()
        }
        .frame(width:size,height: size)
        .onTapGesture {
            withAnimation{
                helper.overlayImage.toggle()
            }
        }
    }
    
    var optionalImages:some View{
        HStack{
            selectedTent.img
            .resizable()
            .frame(width:50,height: 50)
            .padding(2)
            .background{
                Rectangle().fill(Color.white)
            }
            .hLeading()
        }
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
            tentBarHeaderSwitch
            //modelButtons
        }
        .hLeading()
    }
    
    @ViewBuilder
    var modelButtons: some View{
        if helper.header == .MODEL_3D{
            HStack{
                Button(action: toggleBorder){
                    buttonImage("ellipsis.circle",font: TOP_BAR_FONT,foreground: Color.white)
                }
                .hTrailing()
                Button(action: toggleBorder){
                    buttonImage("ellipsis.circle",font: TOP_BAR_FONT,foreground: Color.white)
                }
                .hTrailing()
            }
            .hTrailing()
        }
        
    }
    
    var tentBarHeaderSwitch:some View{
        HStack{
            labelHeaderCell(.MODEL_3D)
            labelHeaderCell(.MODEL_PICTURES)
        }
        .background{
            Color.materialDark
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
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
        VStack{
        }
        .hLeading()
        .padding(.horizontal)
    }
}

//MARK: - FUNCTIONS
extension ModelSceneView{
  
    func navigateBack(){
        navigationViewModel.popPath()
    }
    
    func toggleBorder(){
        sceneViewCoordinator.toggleDimensionBox()
    }
    
}
