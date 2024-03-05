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
            .safeAreaInset(edge: .top){
                topLabel
            }
            .modifier(NavigationViewModifier(color:.black))
            .navigationDestination(for: TentItem.self){  tent in
                ModelSceneView(selectedTent:tent)
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

//MARK: - MAIN CONTENT
extension HomeView{
    
    var mainContent:some View{
        ZStack{
            content
            shapedMenu
         }
    }
    
    var content:some View{
        VStack(spacing:V_HOME_SPACING){
            scrollContainer
        }
        .hCenter()
    }
    
}

//MARK: - SCROLLCONTAINER
extension HomeView{
    var scrollContainer:some View{
        ScrollView{
            VStack{
                carouselSection
             }
            
        }
        .vTop()
    }
}

//MARK: - CAROUSELSECTION
extension HomeView{
    
    var carouselSection:some View{
        VStack{
            inspirationLabel
            carouselContent
         }
    }
    
    var inspirationLabel:some View{
        HStack{
           inspirationtext
           inspirationButton
        }
        .padding([.horizontal])
    }
    
    var inspirationtext:some View{
        Text("Våra tält")
        .font(.title)
        .bold()
        .foregroundStyle(Color.white).hLeading()
    }
    
    var inspirationButton:some View{
        Button(action: { }){
            Image(systemName: "arrow.right")
             .font(.title)
             .bold()
             .foregroundStyle(Color.white)
        }
    }
    
    var carouselContent:some View{
        ZStack{
            GeometryReader{ reader in
                carousel(reader.size.width*0.75)
                .hCenter()
            }
        }
        .frame(height: HOME_CAROUSEL_HEIGHT)
    }
    
    func carousel(_ width:CGFloat) ->some View{
        HomeCarousel(
                 data: $firestoreViewModel.tentAssets,
                 width: width,
                 edge: .trailing)
        .overlay{
            if !firestoreViewModel.hasTents{
                SpinnerAnimation()
                .frame(width: width/4.0,height: width/4.0)
                .foregroundStyle(Color.lightGold)
                .hCenter()
                .vCenter()
            }
            
        }
    }
     
}

//MARK: - TOP LABEL
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
    
    var topLabel:some View{
        HStack{
           labelText
           labelImage
        }
        .padding(.horizontal)
   }
}

//MARK: -- BOTTOMBAR
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
