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
    init() {
        self._arViewCoordinator = StateObject(wrappedValue: ARViewCoordinator())
    }
            
    var body: some View{
        ZStack{
        Color.black
#if targetEnvironment(simulator)
        loadingARKitText
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
         ZStack{
             ARViewContainer(arViewCoordinator: arViewCoordinator)
             if arViewCoordinator.selectedTent == nil {
                 loadingARKitText
             }
         }
    }
   
    var loadingARKitText:some View{
        Text("Pick a tent to place in world")
            .font(.headline)
            .foregroundStyle(Color.white)
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
    
    func onSelectedItem(tent:TentItem) ->Void{
        arViewCoordinator.newSelectedTent(tent)
    }
    
    func onRemoveSelectedItem(){
        withAnimation{
            arViewCoordinator.removeSelectedTent()
        }
    }
}

//MARK: - SELECTED TENT
extension ModelARView{
    
    var tentLabel:some View{
        Text(arViewCoordinator.selectedTent?.title ?? "")
            .font(.subheadline)
            .hCenter()
    }
    
    var tentImage:some View{
        arViewCoordinator.selectedTent?.img
        .resizable()
        .frame(width: 50.0,height: 50.0)
    }
    
    var clearTent:some View{
        Button(action: onRemoveSelectedItem, label: {
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
        }.hLeading()
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
        .frame(alignment: .trailing)
    }
    
    var toggleModelButtons:some View{
        HStack{
            removeModelButton
            placeModelButton.hCenter()
        }
        .opacity(arViewCoordinator.selectedTent == nil ? 0.5 : 1.0)
        .disabled(arViewCoordinator.selectedTent == nil)
    }
    
    var interactButtons:some View{
        HStack{
            toggleModelButtons
            showCarouselButton
        }
    }
    
    var bottomButtons:some View{
        VStack{
            if arViewCoordinator.selectedTent != nil{
                selectedTentContainer
            }
            interactButtons
        }
        .padding([.leading,.trailing])
    }
}
