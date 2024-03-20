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
            .safeAreaInset(edge: .top){
                labelContainer
            }
            .modifier(NavigationViewModifier())
            .navigationDestination(for: Tent.self){  tent in
                ModelSceneView(selectedTent:tent)
            }
            .navigationDestination(for: TentsNavigator.self){  navigator in
                TentsView(navigator:navigator)
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
                NavigationSection(labelText: "Katalog",
                                  action: navigateToTents,
                                  content: brandContent,
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

//MARK: - BRAND-SECTION
extension HomeView{
    var brandContent:some View{
        GeometryReader{ reader in
            ScrollView(.horizontal){
                HStack(spacing: V_SPACING_REG){
                    brandButtons(reader.size.width)
                }
            }
       }
        .hCenter()
        .frame(height: HOME_BRAND_HEIGHT)
        .overlay{
            if firestoreViewModel.loadingState(.TENT_ASSETS){
                SpinnerAnimation()
            }
        }
    }
    
    func brandButtons(_ maxWidth:CGFloat)-> some View{
        ForEach(firestoreViewModel.weraAsset?.brands ?? [],id:\.self){ brand in
            let category_brand = brand.split(separator: "-")
            if let brand = category_brand.first{
                DropShadowButton(buttonText: String(brand),
                                 frameWidth: maxWidth,
                                 action:{
                    navigateToTentsBy(category_brand: category_brand)
                })
            }
        }
     }
  
}

//MARK: - CAPTURED-IMAGES-SECTION
extension HomeView{
    var userLatestContent:some View{
        LazyVGrid(columns: [GridItem(),GridItem()],
                  alignment: .center,
                  spacing: V_GRID_SPACING,
                  pinnedViews: .sectionHeaders){
            ForEach(CoreDataFetcher.fetchedRequestWithLimit(limit: 300,
                                                            sortedOn: "date"),id:\.self){ item in
                screenshotCard(item)
                .padding(.vertical)
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
            FlippedCard(image: Image(uiImage: uiImage),
                        label: item.label,
                        modelId: item.modelId,
                        labelText: item.name ?? "",
                        descriptionText: item.shortDesc ?? "",
                        dateText: item.date?.toISO8601String() ?? "",
                        height: HOME_CAPTURED_HEIGHT,
                        ignoreTapGesture: true)
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
            Text("Wera.").font(.title).bold().foregroundStyle(Color.lightGold.opacity(0.5)).hLeading()
            Text("Sedan 1995.").font(.headline).foregroundStyle(Color.lightGold).hLeading()
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
    
    func navigateToTentsBy(category_brand:[String.SubSequence]){
        if category_brand.count == 2{
            if let brand = category_brand.first,
               let cataloge = category_brand.last{
               let tentsHelper = TentsNavigator(cataloge: String(cataloge),
                                                brand: String(brand))
                 navigationViewModel.appendToPathWith(tentsHelper)
            }
            
        }
    }
    
    func navigateToCapturedImages(){
        navigationViewModel.appendToPathWith(ModelRoute.ROUTE_CAPTURED_IMAGES)
    }
    
    
}
