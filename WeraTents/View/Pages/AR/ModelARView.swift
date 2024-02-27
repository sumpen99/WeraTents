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
    @State var capturedImageCount:Int = 0
    @State var flashScreen:Bool = false
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
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom){
            bottomButtons
        }
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            topButtons
        }
        .overlay{
            carouselContent
        }
        .overlay{
            if flashScreen{
                flashView
            }
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
    
    var flashView:some View{
        ZStack{
            Color.white
        }
        .task{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                flashScreen = false
            }
        }
        .ignoresSafeArea()
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
    
    func captureImage(){
        withAnimation{
            capturedImageCount += 1
            flashScreen = true
        }
    }
    
    func removeModel(){
#if targetEnvironment(simulator)
        arViewCoordinator.modelState = .HAS_SELECTION
#else
        arViewCoordinator.action(.REMOVE_3D_MODEL)
#endif
    }
    
    func placeModel(){
#if targetEnvironment(simulator)
        arViewCoordinator.modelState = .HAS_MODEL
#else
        arViewCoordinator.action(.PLACE_3D_MODEL)
#endif
    }
    
    func onSelectedItem(tent:TentItem) ->Void{
#if targetEnvironment(simulator)
        arViewCoordinator.modelState = arViewCoordinator.selectedTent == nil ? .HAS_SELECTION : arViewCoordinator.modelState
        arViewCoordinator.selectedTent = tent
#else
        arViewCoordinator.newSelectedTent(tent)
#endif
    }
}

//MARK: - BUTTONS
extension ModelARView{
    
    var navigateBackButton:some View{
        BackButton(color:.black,action:releaseMemory)
        .hLeading()
    }
    
    var badge:some View{
        ZStack{
            Circle().fill(Color.white)
            Text("\(capturedImageCount)")
            .foregroundStyle(Color.black)
            .bold()
         }
        .frame(width: 25.0,height: 25.0)
        .hTrailing()
        .vTop()
        .offset(x:5,y:-11)
    }
    
    var navigateToCapturedImagesButton:some View{
        Button(action: { } , label: {
            ZStack{
                Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .imageScale(.medium)
                .bold()
                .foregroundStyle(Color.white)
            }
            .background{
                if capturedImageCount != 0{
                    badge
                }
            }
        })
        .hTrailing()
        .symbolEffect(.bounce.down, value: capturedImageCount)
     }
    
    var captureImageButton:some View{
        Button(action: captureImage, label: {
            roundedImage("camera.metering.center.weighted.average",font:.largeTitle,
                         scale:.large,
                         radius: 70.0,
                         foreground: Color.darkGreen,
                         background: Color.white)
        })
    }
    
    var placeModelButton:some View{
        Button(action: {
            withAnimation{
                placeModel()
            }
        },label:   {
            roundedImage("plus",font:.largeTitle,
                         scale:.large,
                         radius: 70.0,
                         foreground: Color.darkGreen)
        })
    }
    
    var removeModelButton:some View{
        Button(action: {
            withAnimation{
                removeModel()
            }
        },label:{
            roundedImage("minus",
                         font:.title,
                         scale:.medium,
                         radius: 40.0,
                         foreground: Color.red)
        })
    }
    
    var showCarouselButton:some View{
        Button(action: {
            if !firestoreViewModel.hasTents{ return }
            withAnimation(.easeInOut(duration: 0.45)){
                showCarousel.toggle()
            }
            
        },label:{
            roundedImage("tent",
                         font:.title,
                         scale:.medium,
                         radius: 60.0,
                         foreground: Color.darkGreen)
        })
        .frame(alignment: .trailing)
    }
    
    @ViewBuilder
    func centerButton() -> some View{
        ZStack{
            if arViewCoordinator.activeAddButton{
                placeModelButton
            }
            else if arViewCoordinator.activeCaptureButton{
                captureImageButton
            }
        }
        .transition(.scale)
     }
    
    func leadingButton() -> some View{
        ZStack{
            if arViewCoordinator.activeRemoveButton{
                removeModelButton
            }
        }
        .rotationEffect(.degrees(arViewCoordinator.activeRemoveButton ? 360 : 0))
     }
    
    var interactButtons:some View{
        ZStack{
            leadingButton().hLeading()
            centerButton().hCenter()
            showCarouselButton.hTrailing()
        }
    }
    
    var bottomButtons:some View{
        interactButtons
        .padding([.leading,.trailing])
    }
    
    var topButtons:some View{
        HStack{
            BackButton(imgLabel: "xmark",color: .white,action: releaseMemory).hLeading()
            navigateToCapturedImagesButton
        }
        .padding()
    }
}
