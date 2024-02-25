//
//  ARView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

struct ModelARView: View {
    @EnvironmentObject var firestoreViewModel:FirestoreViewModel
    @StateObject private var arViewCoordinator: ARViewCoordinator
    @State var showCarousel:Bool = false
    @State var selectedTent:TentItem?
    init() {
        self._arViewCoordinator = StateObject(wrappedValue: ARViewCoordinator())
    }
            
    var body: some View{
        ZStack{
        Color.lightGreen
#if targetEnvironment(simulator)
        simulatorContent
#else
        arContent
#endif
       }
        .task{
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                arViewCoordinator.state = .LOADING
            })
            
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom){
            bottomButtons
        }
        .toolbar(.hidden)
        .customBackButton(imgLabel: "xmark",color: .white,action: releaseMemory)
        .overlay{
            carouselContent
        }
   
    }
}


//MARK: - MAIN CONTENT
extension ModelARView{
    @ViewBuilder
     var arContent:some View{
         if arViewCoordinator.state != .DONE{
             Text("Loading")
            .font(.system(size: 75.0,weight: .bold))
         }
         if arViewCoordinator.state != .INITIAL{
             ARViewContainer(arViewCoordinator: arViewCoordinator)
            .onAppear{
                arViewCoordinator.state = .DONE
            }
         }
    }
    
    var simulatorContent:some View{
        Text("Simulator View").hCenter().vCenter()
    }
}

//MARK: - CAROUSEL
extension ModelARView{
    var carouselContent:some View{
        GeometryReader{ reader in
            ZStack{
                if showCarousel{
                    Carousel(isOpen:$showCarousel,
                             data: $firestoreViewModel.tents,
                             size: min(reader.size.width,reader.size.height)/3,
                             edge: .trailing,
                             onSelected:onSelectedItem)
                }
            }
            .hCenter()
            .vCenter()
        }
        
    }
    
    func onSelectedItem(tent:TentItem) ->Void{
        self.selectedTent = tent
    }
}




//MARK: - FUNCTIONS
extension ModelARView{
    func releaseMemory(){
        arViewCoordinator.kill()
     }
    
    func removeModel(){
        arViewCoordinator.action(.REMOVE_3D_MODEL)
    }
    
    func placeModel(){
        arViewCoordinator.action(.PLACE_3D_MODEL)
    }
}

//MARK: - SELECTED TENT
extension ModelARView{
    
    var tentLabel:some View{
        Text(self.selectedTent?.title ?? "")
            .font(.subheadline)
            .hCenter()
    }
    
    var tentImage:some View{
        self.selectedTent?.img
        .resizable()
        .frame(width: 50.0,height: 50.0)
    }
    
    var clearTent:some View{
        Button(action: {
            withAnimation{
                selectedTent = nil
            }
        }, label: {
            roundedImage("chevron.left",
                         font:.body,
                         scale:.large,
                         radius: 35.0,
                         foreground: Color.darkGreen,
                         background: Color.clear)
        })
    }
    
    var selectedTentContainer:some View{
        HStack{
            tentImage
            tentLabel
            clearTent
        }
        .background{
            Color.white.opacity(0.8)
        }
        .transition(.move(edge: .leading))
    }
}

//MARK: - BUTTONS
extension ModelARView{
    
    var navigateBackButton:some View{
        BackButton(color:.black,action:releaseMemory)
        .hLeading()
    }
    
    var placeModelButton:some View{
        Button(action: placeModel, label: {
            roundedImage("plus",font:.largeTitle,
                         scale:.large,
                         radius: 70.0,
                         foreground: Color.darkGreen)
        })
    }
    
    var removeModelButton:some View{
        Button(action: removeModel, label: {
            roundedImage("minus",
                         font:.title,
                         scale:.medium,
                         radius: 40.0,
                         foreground: Color.darkGreen)
        })
    }
    
    var showCarouselButton:some View{
        Button(action: {
            if !firestoreViewModel.hasTents{ return }
            withAnimation(.easeInOut(duration: 0.45)){
                showCarousel.toggle()
            }
            
        }, label: {
            roundedImage("tent",
                         font:.title,
                         scale:.medium,
                         radius: 60.0,
                         foreground: Color.darkGreen)
        })
    }
    
    var interactButtons:some View{
        HStack{
            removeModelButton
            placeModelButton.hCenter()
            showCarouselButton
        }
    }
    
    var bottomButtons:some View{
        VStack{
            if selectedTent != nil{
                selectedTentContainer
            }
            interactButtons
        }
        .padding([.leading,.trailing])
    }
}
