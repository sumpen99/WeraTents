//
//  HomeView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-21.
//

import SwiftUI

enum ModelRoute: Identifiable{
    case ROUTE_AR
    
    var id: Int {
        hashValue
    }
    
}

struct HomeView:View {
    @EnvironmentObject var firestoreViewModel:FirestoreViewModel
    @StateObject var navigationViewModel = NavigationViewModel()
    @State var showCarousel:Bool = false
       
    var content:some View{
        ZStack{
            bottomButtons
        }
        .hCenter()
        .vCenter()
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            content
            .modifier(NavigationViewModifier(color:.lightGreen))
            .navigationDestination(for: ModelRoute.self){  route in
                switch route{
                case .ROUTE_AR: ModelARView()
                }
            }
            .overlay{
                carouselContent
            }
       }
    }
}

//MARK: - CAROUSEL
extension HomeView{
    var carouselContent:some View{
        GeometryReader{ reader in
            ZStack{
                if showCarousel{
                    Carousel(isOpen:$showCarousel,
                             data: $firestoreViewModel.tents,
                             size: min(reader.size.width,reader.size.height)/3,
                             edge: .trailing)
                }
            }
            .hCenter()
            .vCenter()
        }
        
    }
}

//MARK: -- BUTTONS
extension HomeView{
    var navModelARButton:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_AR)}, label: {
            roundedImage("camera",font:.largeTitle,scale:.large,radius: 80.0,foreground: Color.white,background: Color.darkGreen)
        })
    }
    
    var showCarouselButton:some View{
        Button(action: {
            if !firestoreViewModel.hasTents{ return }
            withAnimation(.easeInOut(duration: 0.45)){
                showCarousel.toggle()
            }
            
        }, label: {
            roundedImage("info",
                         font:.title,
                         scale:.medium,
                         radius: 45.0,
                         foreground: Color.white,
                         background: Color.darkGreen)
        })
    }
    
    @ViewBuilder
    var bottomButtons:some View{
        HStack{
            showCarouselButton
            navModelARButton.hCenter()
            showCarouselButton
        }
        .hCenter()
        .vBottom()
        .padding([.leading,.trailing])
        
    }
}
