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
    @State var showCarousel:Bool = false
 
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            mainContent
            .modifier(NavigationViewModifier(color:.clear))
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
            background
            content
            shapedMenu
         }
    }
    
    var background:some View{
        ZStack{
            Color.black
            Image("weratent-logo-horn")
                .resizable()
                .frame(width:100,height:100)
         }
         .ignoresSafeArea()
    }
    
    var content:some View{
        VStack(spacing:V_HOME_SPACING){
            topLabel.padding([.horizontal])
            ScrollView{
                VStack{
                    carouselSection
                 }
                
            }
            .vTop()
        }
        .padding([.top,.bottom])
        .hCenter()
    }
    
    var topLabel:some View{
        HStack{
            VStack{
                Text("Wera.").font(.title).bold().foregroundStyle(Color.white).hLeading()
                Text("Sedan 1995.").font(.headline).foregroundStyle(Color.white).hLeading()
            }.hLeading()
            
           Image("weratent-logo-horn")
            .resizable()
            .frame(width:80,height: 80)
            
        }
   }
    
}

//MARK: - LIST CONTENT CONTENT
extension HomeView{
   
    var instructionLabel:some View{
        HStack{
           Text("Videos").font(.title).bold().foregroundStyle(Color.white).hLeading()
            
           Image(systemName: "arrow.right")
            .font(.title)
            .bold()
            .foregroundStyle(Color.white)
            
        }
        .background{
            Color.red
        }
    }
    
    var manualsLabel:some View{
        HStack{
           Text("Monteringsanvisningar").font(.title).bold().foregroundStyle(Color.white).hLeading()
            
           Image(systemName: "arrow.right")
            .font(.title)
            .bold()
            .foregroundStyle(Color.white)
            
        }
        .background{
            Color.yellow
        }
    }
    
    var listContent:some View{
        List{
            VStack(spacing:0){
                HStack{
                    Text(BULLET).frame(width:10).hLeading()
                    Text(BULLET).frame(width:10).hTrailing()
                }
                HStack{
                    Text(BULLET).frame(width:10).hLeading()
                    Text(BULLET).frame(width:10).hTrailing()
                }
                HStack{
                    Text(BULLET).frame(width:10).hLeading()
                    Text(BULLET).frame(width:10).hTrailing()
                }
                HStack{
                    Text(BULLET).frame(width:10).hLeading()
                    Text(BULLET).frame(width:10).hTrailing()
                }
                HStack{
                    Text(BULLET).frame(width:10).hLeading()
                    Text(BULLET).frame(width:10).hTrailing()
                }
            }
            .listRowBackground(Color.darkGreen.opacity(0.5))
            .padding()
            .background(){
                RoundedRectangle(cornerRadius: 10.0).fill(Color.white)
            }
        }
        .padding()
    }
}

//MARK: - CAROUSEL
extension HomeView{
    
    var carouselSection:some View{
        VStack{
            inspirationLabel.padding([.horizontal])
            carouselContent
         }
    }
    
    var inspirationLabel:some View{
        HStack{
           Text("Inspiration").font(.title).bold().foregroundStyle(Color.white).hLeading()
            
            Button(action: { }){
                Image(systemName: "arrow.right")
                 .font(.title)
                 .bold()
                 .foregroundStyle(Color.white)
            }
        }
    }
    
    var carouselContent:some View{
        ZStack{
            GeometryReader{ reader in
                HomeCarousel(
                         data: $firestoreViewModel.tents,
                         width: reader.size.width*0.75,
                         edge: .trailing).hCenter()
            }
        }
        .frame(height: HOME_CAROUSEL_HEIGHT)
        
    }
}

//MARK: -- BOTTOMBAR
extension HomeView{
    var navModelARButton:some View{
        Button(action: { navigationViewModel.switchPathToRoute(ModelRoute.ROUTE_AR)}, label: {
            buttonImage("rectangle.split.1x2", font: .largeTitle, foreground: Color.lightBlue)
                .imageScale(.large)
            .padding(15.0)
            .background{
                RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU).fill(Color.materialDarkest)
            }
        })
        .offset(y:-4)
    }
    
    var videoButton:some View{
        Button(action: {
            if !firestoreViewModel.hasTents{ return }
            withAnimation(.easeInOut(duration: 0.45)){
                showCarousel.toggle()
            }
            
        }, label: {
            buttonImage("video.circle.fill", font: .title, foreground: Color.lightBlue)
            .padding(10.0)
            .background{
                RoundedRectangle(cornerRadius: CORNER_RADIUS_MENU/2.0).fill(Color.materialDarkest)
            }
        })
    }
    
    var accountButton:some View{
        Button(action: {
            if !firestoreViewModel.hasTents{ return }
            withAnimation(.easeInOut(duration: 0.45)){
                showCarousel.toggle()
            }
            
        }, label: {
            buttonImage("person.crop.circle.fill", font: .title, foreground: Color.lightBlue)
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
