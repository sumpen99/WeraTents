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
                case .ROUTE_TENTS:              TentsView()
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
            scrollContainer
        }
        .overlay{
            menuAnimation
        }
        .vTop()
    }
    
    var menuAnimation:some View{
        ZStack{
           overlayedMenu
           MenuButtonAnimation(openMenuSwitch: $openMenuSwitch)
        }
    }
   
    @ViewBuilder
    var overlayedMenu:some View{
        if openMenuSwitch{
            LayOverView(closeView: $openMenuSwitch)
        }
    }
}

//MARK: - SCROLL-CONTAINER
extension HomeView{
    var scrollContainer:some View{
        ScrollView{
            VStack(spacing:V_GRID_SPACING){
                NavigationSection(labelText: "Våra tält",
                                  action: navigateToTents,
                                  content: carouselContent)
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
    
    var labelContainer:some View{
        HStack{
           labelText
           labelImage
        }
        .padding(.horizontal)
    }
    
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
    
}

//MARK: - FUNCTIONS
extension HomeView{
    
    func navigateToTents(){
        navigationViewModel.appendToPathWith(ModelRoute.ROUTE_TENTS)
    }
    
    func calculatedWidth(maxWidth:CGFloat) -> CGFloat{
        let itemCount = 3.0
        let padding = CGFloat(itemCount-1)*V_SPACING_REG
        let width = (maxWidth-padding)/(itemCount+1)
        return width < 0 ? 0 : width
    }
}
