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
    @State var brandModel:BrandModel?
  
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            mainContent
            .safeAreaInset(edge: .top){
                labelContainer
            }
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
        scrollContainer
        .overlay{
            MenuButtonAnimation(openMenuSwitch: $openMenuSwitch)
        }
    }
}

//MARK: - SCROLL-CONTAINER
extension HomeView{
    var scrollContainer:some View{
        ScrollView{
            LazyVStack(spacing:V_GRID_SPACING){
                NavigationSection(labelText: "Våra tält",
                                  action: navigateToTents,
                                  content: carouselContent,
                                  backgroundColor: Color.white.opacity(0.03))
                NavigationSection(labelText: "För dig",
                                  action: navigateToCapturedImages,
                                  content: userLatestContent,
                                  backgroundColor: Color.white.opacity(0.03))
             }
        }
        .scrollIndicators(.hidden)
    }
}

//MARK: - CAROUSEL-SECTION
extension HomeView{
    var carouselContent:some View{
        GeometryReader{ reader in
            carousel(reader.size.width)
            .hCenter()
        }
        .frame(height: HOME_CAROUSEL_HEIGHT+HOME_BRAND_HEIGHT)
    }
    
    func carousel(_ width:CGFloat) ->some View{
        HomeCarousel(
                brandModel:$brandModel,
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
    var userLatestContent:some View{
        LazyVGrid(columns: [GridItem(),GridItem()]
                  ,alignment: .center,
                  spacing: V_GRID_SPACING,
                  pinnedViews: .sectionHeaders){
            ForEach(CoreDataFetcher.fetchedRequestWithLimit(limit: 300,
                                                            sortedOn: "date"),id:\.self){ item in
                screenshotCard(item)
             }
        }
        .padding(.horizontal)
        .padding(.bottom,MENU_HEIGHT)
    }
    
    @ViewBuilder
    func screenshotCard(_ item:ScreenshotModel) -> some View{
        if let image = item.image,
           let imageData = image.data,
           let uiImage = UIImage(data: imageData){
            PressedCard(image: Image(uiImage: uiImage),
                        labelText: item.name ?? "",
                        descriptionText: item.date?.toISO8601String() ?? "",
                        scaleFactor: 0.95,
                        height: HOME_CAPTURED_HEIGHT,
                        imageLabel: "square.split.diagonal.2x2.fill"){
                self.brandModel = BrandModel(brand: item.label,
                                             modelId: item.modelId)
              
            }
       }
    }
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
    
    func navigateToCapturedImages(){
        navigationViewModel.appendToPathWith(ModelRoute.ROUTE_CAPTURED_IMAGES)
    }
    
    func calculatedWidth(maxWidth:CGFloat) -> CGFloat{
        let itemCount = 3.0
        let padding = CGFloat(itemCount-1)*V_SPACING_REG
        let width = (maxWidth-padding)/(itemCount+1)
        return width < 0 ? 0 : width
    }
}
