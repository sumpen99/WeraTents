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
    @StateObject var navigationViewModel = NavigationViewModel()
    @StateObject private var firestoreViewModel: FirestoreViewModel
    @State var showCarousel:Bool = false
    
    init(){
        self._firestoreViewModel = StateObject(wrappedValue: FirestoreViewModel())
    }
 
    var carouselContent:some View{
        GeometryReader{ reader in
            ZStack{
                if showCarousel{
                    Carousel(data: $firestoreViewModel.tents,
                             size: min(reader.size.width,reader.size.height)/3,
                             edge: .trailing)
                }
            }
            .hCenter()
            .vCenter()
        }
        
    }
    
    var content:some View{
        ZStack{
            Color.clear
        }
        .hCenter()
        .vCenter()
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            content
            .ignoresSafeArea(.all)
            .safeAreaInset(edge: .bottom){
                bottomButtons
            }
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
        .task {
            firestoreViewModel.loadImageAssets()
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
            withAnimation(.easeInOut(duration: 0.45)){
                showCarousel.toggle()
            }
            
        }, label: {
            roundedImage("tent",
                         font:.title,
                         scale:.medium,
                         radius: 60.0,
                         foreground: Color.white,
                         background: Color.darkGreen)
        })
    }
    
    @ViewBuilder
    var bottomButtons:some View{
        HStack{
            navModelARButton.hCenter()
            showCarouselButton
        }
        .padding([.leading,.trailing])
        
    }
}
