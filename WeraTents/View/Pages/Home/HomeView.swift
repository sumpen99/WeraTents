//
//  HomeView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI
struct HomeView:View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @State var openMenuSwitch:Bool = false
  
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            mainContent
            .modifier(NavigationViewModifier())
            .navigationDestination(for: TentItem.self){  tent in
                ModelSceneView(selectedTent:tent)
            }
            .navigationDestination(for: VideoResourcesItem.self){  videoResourcesItem in
                YoutubeView(videoResourcesItem: videoResourcesItem)
            }
            .navigationDestination(for: PdfResourcesItem.self){  pdfResourcesItem in
                PdfView(pdfResourcesItem: pdfResourcesItem)
            }
            .navigationDestination(for: ModelRoute.self){  route in
                switch route{
                case .ROUTE_AR:                 ModelARView()
                case .ROUTE_CAPTURED_IMAGES:    CapturedImages()
                 }
            }
        }
    }
}

//MARK: - MAIN-CONTENT
extension HomeView{
    
    var mainContent:some View{
        VStack{
            labelContainer
            scrollContent
        }
        .overlay{
            overlayedMenu
        }
        .vTop()
    }
    
    @ViewBuilder
    var scrollContent:some View{
        ZStack{
            scrollContainer
            MenuButtonAnimation(openMenuSwitch: $openMenuSwitch)
        }
    }
    
    @ViewBuilder
    var overlayedMenu:some View{
        if openMenuSwitch{
            ZStack{
                Color.white.opacity(0.3)
                VStack{
                    HStack{
                        Text("Starta ny AR-upplevelse!")
                        .foregroundStyle(Color.white)
                        .bold()
                        .font(.headline)
                        ZStack{
                            RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU)
                            .fill(Color.materialDark)
                            Image(systemName: "camera.metering.center.weighted")
                            .font(.title3)
                            .foregroundStyle(Color.white)
                            .padding()
                            .frame(width: ICON_WIDTH,height:ICON_WIDTH)
                        }
                        .frame(width: ICON_WIDTH,height:ANIMATED_MENU_HEIGHT)
                    }
                    .hTrailing()
                    HStack{
                        Text("Starta ny AR-upplevelse!")
                        .foregroundStyle(Color.white)
                        .bold()
                        .font(.headline)
                        ZStack{
                            RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU)
                            .fill(Color.materialDark)
                            Image(systemName: "camera.metering.center.weighted")
                            .font(.title3)
                            .foregroundStyle(Color.white)
                            .background{ Color.materialDark }
                            .padding()
                            .frame(width: ICON_WIDTH,height:ICON_WIDTH)
                        }
                        .frame(width: ICON_WIDTH,height:ANIMATED_MENU_HEIGHT)
                    }
                    .hTrailing()
                    
                }
                .transition(.move(edge: .bottom))
                .vBottom()
                .hTrailing()
                .padding(.trailing)
                .padding(.bottom,ANIMATED_MENU_HEIGHT-5)
            }
            .onTapGesture {
                withAnimation{
                    openMenuSwitch.toggle()
                }
            }
            .ignoresSafeArea(.all)
            .vTop()
            .hCenter()
            //.transition(.opacity)
        }
    }
    
}

//MARK: - SCROLL-CONTAINER
extension HomeView{
    var scrollContainer:some View{
        ScrollView{
            VStack(spacing:V_GRID_SPACING){
                NavigationSection(labelText: "Våra tält", action: {}, content: carouselContent)
             }
        }
    }
}

//MARK: - CAROUSEL-SECTION
extension HomeView{
    var carouselContent:some View{
        ZStack{
            GeometryReader{ reader in
                carousel(reader.size.width)
                .hCenter()
            }
        }
        .frame(height: HOME_CAROUSEL_HEIGHT+HOME_BRAND_HEIGHT)
    }
    
    func carousel(_ width:CGFloat) ->some View{
        HomeCarousel(
                 cardWidth: width*0.75,
                 brandWidth: width,
                 edge: .trailing)
        .overlay{
            if firestoreViewModel.loadingState(.TENT_ASSETS){
                SpinnerAnimation(size:width/4.0)
            }
        }
    }
}

//MARK: - CAPTURED-IMAGES-SECTION
extension HomeView{
    
    
}

//MARK: - TOP-LABEL
extension HomeView{
    
    var labelText:some View{
        VStack{
            Text("Wera.").font(.title).bold().foregroundStyle(Color.white).hLeading()
            Text("Sedan 1995.").font(.headline).foregroundStyle(Color.white).hLeading()
        }.hLeading()
    }
    
    var labelImage:some View{
        Image("weratent-logo-horn")
         .resizable()
         .frame(width:80,height: 80)
         .hTrailing()
    }
    
    var labelContainer:some View{
        HStack{
           labelText
           labelImage
        }
        .padding(.horizontal)
    }
     
}

//MARK: - FUNCTIONS
extension HomeView{
    func calculatedWidth(maxWidth:CGFloat) -> CGFloat{
        let itemCount = 3.0
        let padding = CGFloat(itemCount-1)*V_SPACING_REG
        let width = (maxWidth-padding)/(itemCount+1)
        return width < 0 ? 0 : width
    }
}
