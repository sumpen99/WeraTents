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
        VStack(spacing:0){
            listContent
            listContent
        }
        .hCenter()
        .vCenter()
    }
    
    var background:some View{
        Image("background")
        .resizable()
        .ignoresSafeArea()
    }
    
    var body: some View{
        NavigationStack(path:$navigationViewModel.pathTo){
            ZStack{
                background
                content
                shapedMenu
            }
            .modifier(NavigationViewModifier(color:.lightGreen))
            .navigationDestination(for: ModelRoute.self){  route in
                switch route{
                case .ROUTE_AR: ModelARView()
                }
            }
        }
        
    }
}

//MARK: - MAIN CONTENT
extension HomeView{
    
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
            roundedImage("camera",
                         font:.title,
                         scale:.large,
                         radius: 60.0,
                         foreground: Color.materialDark,
                         background: Color.clear)
                .background{
                    Capsule()
                    .fill(Color.white)
                    .frame(width:60,height: 80)
                }
        })
    }
    
    var videoButton:some View{
        Button(action: {
            if !firestoreViewModel.hasTents{ return }
            withAnimation(.easeInOut(duration: 0.45)){
                showCarousel.toggle()
            }
            
        }, label: {
            roundedImage("video.circle.fill",
                         font:.title,
                         scale:.medium,
                         radius: 45.0,
                         foreground: Color.materialDark,
                         background: Color.clear)
            .background{
                Capsule()
                .fill(Color.white)
                .frame(width:45,height: 55)
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
            roundedImage("person.crop.circle.fill",
                         font:.title,
                         scale:.medium,
                         radius: 45.0,
                         foreground: Color.materialDark,
                         background: Color.clear)
            .background{
                Capsule()
                .fill(Color.white)
                .frame(width:45,height: 55)
            }
        })
    }
    
    @ViewBuilder
    var bottomButtons:some View{
        HStack{
            videoButton.padding(.leading)
            navModelARButton.hCenter()
            accountButton.padding(.trailing)
        }
        .padding([.leading,.trailing])
    }
     
    var shapedMenu:some View{
        ZStack{
            ShapeMenu()
                .fill(Color.materialDark.opacity(0.5))
            bottomButtons
       }
        .frame(height:MENU_HEIGHT)
        .padding([.leading,.trailing,.bottom])
        .vBottom()
    }
}

struct ShapeMenu: Shape {
   func path(in rect: CGRect) -> Path {
       let y_middle = MENU_HEIGHT/2.0
       let part = CORNER_RADIUS_MENU*1.5
       let middle = rect.maxX/2.0
       let start = middle-part
       let end = middle+part
       let offY = MENU_HEIGHT*0.8667
       let minY = MENU_HEIGHT*0.1333
       let midOffY = MENU_HEIGHT*0.2333
     return Path { path in
         path.move(to: CGPoint(x: end, y: 0))
         path.addQuadCurve(to: CGPoint(x: rect.maxX-CORNER_RADIUS_MENU,y:0), control: CGPoint(x:rect.maxX-part, y: minY))
         path.addQuadCurve(to: CGPoint(x: rect.maxX-CORNER_RADIUS_MENU, y: MENU_HEIGHT), control: CGPoint(x:rect.maxX, y: y_middle))
         path.addQuadCurve(to: CGPoint(x: end,y:MENU_HEIGHT), control: CGPoint(x:rect.maxX-part, y: offY)) 
         
         path.addQuadCurve(to: CGPoint(x: start,y:MENU_HEIGHT), control: CGPoint(x:middle, y: MENU_HEIGHT+midOffY))
        
         path.addQuadCurve(to: CGPoint(x: CORNER_RADIUS_MENU,y:MENU_HEIGHT), control: CGPoint(x:part, y: offY))
         path.addQuadCurve(to: CGPoint(x: CORNER_RADIUS_MENU,y:0), control: CGPoint(x:0, y: y_middle))
         path.addQuadCurve(to: CGPoint(x: start,y:0), control: CGPoint(x:part, y: MENU_HEIGHT-offY))
         
         path.addQuadCurve(to: CGPoint(x: end,y:0), control: CGPoint(x:middle, y: -midOffY))
         
         /*path.move(to: CGPoint(x: start, y: 0))
         path.addQuadCurve(to: CGPoint(x: CORNER_RADIUS_MENU,y:0), control: CGPoint(x:0+part, y: minY))
         path.addQuadCurve(to: CGPoint(x: CORNER_RADIUS_MENU, y: MENU_HEIGHT), control: CGPoint(x:0, y: y_middle))
         path.addQuadCurve(to: CGPoint(x: start,y:MENU_HEIGHT), control: CGPoint(x:0+part, y: offY))
         path.addQuadCurve(to: CGPoint(x: end,y:MENU_HEIGHT), control: CGPoint(x:middle, y: MENU_HEIGHT+minY*2))
         path.addLine(to: CGPoint(x: end,y:0))
         path.addQuadCurve(to: CGPoint(x: start,y:0), control: CGPoint(x:middle, y: -minY*2))*/
         }
    }
}
