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
            appBackgroundGradient
            .ignoresSafeArea(.all)
            .toolbar(.hidden)
            .safeAreaInset(edge: .top){
                mainContent
            }
            .ignoresSafeArea(edges:[.bottom])
            .navigationDestination(for: Tent.self){  tent in
                ModelSceneView(selectedTent:tent)
            }
            .navigationDestination(for: CatalogeNavigator.self){  navigator in
                TentsView(navigator:navigator)
            }
            .navigationDestination(for: PdfResourceItem.self){  pdfResourceItem in
                PdfContentView(pdfResourceItem: pdfResourceItem)
            }
            .navigationDestination(for: ModelRoute.self){  route in
                switch route{
                case .ROUTE_AR:                 ModelARView()
                case .ROUTE_TENTS:              TentsView()
                case .ROUTE_CAPTURED_IMAGES:    CapturedImages()
                case .ROUTE_PDF:                PdfView()
                case .ROUTE_YOUTUBE:            YoutubeView()
                }
            }
            
        }
        .onTapGesture {
            endTextEditing()
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
                                  action: {
                    navigateToRoute(.ROUTE_TENTS)
                },
                                  content: brandContent,
                                  backgroundColor: Color.section)
                NavigationSection(labelText: "För dig",
                                  action: {
                    navigateToRoute(.ROUTE_CAPTURED_IMAGES)
                },
                                  content: CoreDataSection(limit: 3),
                                  backgroundColor: Color.section)
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
        ForEach(firestoreViewModel.weraAsset?.brands ?? [],id:\.self){ brand_category in
            let brand_category_values = brand_category.split(separator: "-")
            if let brand = brand_category_values.first{
                DropShadowButton(buttonText: String(brand),
                                 frameWidth: maxWidth,
                                 action:{
                    navigateToTentsBy(brand_category: brand_category_values)
                })
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

//MARK: - KEYBOARD ON DONE
extension HomeView{
   
    var toolbarButton:some View{
        Button("Klar") {
            endTextEditing()
        }
        .bold()
        .foregroundStyle(Color.blue)
    }
    
}

//MARK: - FUNCTIONS
extension HomeView{
    
    func navigateToTentsBy(brand_category:[String.SubSequence]){
        if brand_category.count == 2{
            if let brand = brand_category.first,
               let cataloge = brand_category.last{
               let tentsHelper = CatalogeNavigator(cataloge: String(cataloge),
                                                brand: String(brand))
                 navigationViewModel.appendToPathWith(tentsHelper)
            }
            
        }
    }
    
    func navigateToRoute(_ toGoTo:ModelRoute){
        navigationViewModel.appendToPathWith(toGoTo)
    }
    
    
}
