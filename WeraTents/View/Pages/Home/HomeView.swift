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
        .vTop()
    }
    
    var scrollContent:some View{
        ZStack{
            scrollContainer
            shapedMenu
        }
    }
    
    /*
     VStack{
         labelContainer
         scrollContent
     }
     .overlay{
         ZStack{
             Color.red
         }
         .ignoresSafeArea(.all)
         .vTop()
         .hCenter()
     }
     .vTop()
     
     */
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

//MARK: - BRAND -SECTION
extension HomeView{
    var brandContent:some View{
        GeometryReader{ reader in
            ScrollView(.horizontal){
                brandButtons(reader.size.width)
            }
        }
        .frame(height: HOME_BRAND_HEIGHT)
        .hCenter()
    }
    
    @ViewBuilder
    func brandButtons(_ size:CGFloat) -> some View{
        if size > 0{
            HStack(spacing: V_SPACING_REG){
                DropShadowButton(buttonText: "Adventure",frameWidth: calculatedWidth(maxWidth: size), action: {})
                DropShadowButton(buttonText: "Bohus",frameWidth: calculatedWidth(maxWidth: size), action: {})
                DropShadowButton(buttonText: "Vivalid",frameWidth: calculatedWidth(maxWidth: size), action: {})
            }
        }
    }
    
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

//MARK: -- BOTTOM-BAR
extension HomeView{
    var navModelARButton:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_AR)}, label: {
            buttonImage("rectangle.split.1x2", font: .largeTitle, foreground: Color.lightGold)
                .imageScale(.large)
            .padding(15.0)
            .background{
                RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU).fill(Color.materialDarkest)
            }
        })
        .offset(y:-4)
    }
    
    var videoButton:some View{
        Button(action: {}, label: {
            buttonImage("video.circle.fill", font: .title, foreground: Color.lightGold)
            .padding(10.0)
            .background{
                RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU/2.0).fill(Color.materialDarkest)
            }
        })
    }
    
    var accountButton:some View{
        Button(action: {}, label: {
            buttonImage("person.crop.circle.fill", font: .title, foreground: Color.lightGold)
            .padding(10.0)
            .background{
                RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU/2.0).fill(Color.materialDarkest)
            }
        })
    }
    
    @ViewBuilder
    var bottomButtons:some View{
        HStack{
            videoButton
            navModelARButton.hCenter()
            accountButton
        }
        .padding([.leading,.trailing])
    }
     
    var shapedMenu:some View{
        ZStack{
            RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU).fill(Color.materialDark)
            OvalShapeMenu()
            .fill(Color.materialDark)
            bottomButtons
       }
        .frame(height:MENU_HEIGHT)
        .padding([.bottom,.leading,.trailing])
        .vBottom()
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
