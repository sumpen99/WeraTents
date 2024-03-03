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
    @StateObject private var sceneViewCoordinator: SceneViewCoordinator
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    @State var showCarousel:Bool = false
    @State var flashScreen:Bool = false
    @State var capturedImageCount:Int = 0
    @State var savingScreenShot:Bool = false
    init() {
        self._arViewCoordinator = StateObject(wrappedValue: ARViewCoordinator())
        self._sceneViewCoordinator = StateObject(wrappedValue: SceneViewCoordinator())
    }
            
    var body: some View{
        mainContent
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
    var mainContent:some View{
        ZStack{
        Color.black
        arContent
       }
    }
    
     var arContent:some View{
         ZStack{
             ARViewContainer(arViewCoordinator: arViewCoordinator)
         }
         .task {
             arViewCoordinator.run()
         }
    }
    
    var flashView:some View{
        ZStack{
            Color.white
        }
        .task{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
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

//MARK: - BOTTOMBAR
extension ModelARView{
    var captureImageButton:some View{
        Button(action: captureImage, label: {
            roundedImage("camera.metering.center.weighted.average",font:.largeTitle,
                         scale:.large,
                         radius: 70.0,
                         foreground: Color.lightBlue,
                         background: Color.white)
        })
        .disabled(savingScreenShot)
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
                         foreground: Color.lightBlue)
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
                         foreground: Color.lightBlue)
        })
        .frame(alignment: .trailing)
    }
    
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
}

//MARK: - TOPBAR
extension ModelARView{
     
    var navigateToCapturedImagesButton:some View{
        Button(action: navigateToCapturedImages , label: {
            buttonImage("photo.on.rectangle.angled",font: TOP_BAR_FONT,foreground: Color.white)
            .badge(count: $capturedImageCount)
        })
        .hTrailing()
        .symbolEffect(.bounce.down, value: capturedImageCount)
        .badge(1)
     }
    
    var topButtons:some View{
        HStack{
            BackButtonAction(action: navigateBack)
            navigateToCapturedImagesButton
        }
        .hLeading()
        .padding()
    }
}

//MARK: - FUNCTIONS
extension ModelARView{
    
    func navigateToCapturedImages(){
        arViewCoordinator.pause()
        arViewCoordinator.action(.REMOVE_3D_MODEL)
        navigationViewModel.appendToPathWith(ModelRoute.ROUTE_CAPTURED_IMAGES)
    }
    
    func navigateBack(){
        releaseMemory()
        navigationViewModel.popPath()
    }
    
    func releaseMemory(){
        arViewCoordinator.kill()
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
    
    func onSelectedItem(tent:TentMeta) ->Void{
#if targetEnvironment(simulator)
        arViewCoordinator.modelState = arViewCoordinator.selectedTentMeta == nil ? .HAS_SELECTION : arViewCoordinator.modelState
        arViewCoordinator.selectedTentMeta = tent
#else
        arViewCoordinator.newSelectedTent(tent)
#endif
    }
    
    func captureImage(){
        savingScreenShot = true
        flashScreen = true
        capturedImageCount += 1
        let managedObjectContext = PersistenceController.shared.container.viewContext
#if targetEnvironment(simulator)
        let model = ScreenshotModel(context:managedObjectContext)
        model.buildWithName(arViewCoordinator.selectedTentMeta)
        do{
            try PersistenceController.saveContext()
            savingScreenShot = false
        }
        catch{
            appStateViewModel.activateToast(.FAIL,"Error"){
                savingScreenShot = false
            }
        }
#else
        arViewCoordinator.captureSnapshot(){ data in
            if let data = data{
                 let model = ScreenshotModel(context:managedObjectContext)
                model.buildWithName(arViewCoordinator.selectedTentMeta?.title ?? "")
                let image = ScreenshotImage(context:managedObjectContext)
                image.id = model.id
                image.data = data
                model.image = image
                do{
                    try PersistenceController.saveContext()
                    savingScreenShot = false
                }
                catch{
                    appStateViewModel.activateToast(.FAIL,"Error"){
                        savingScreenShot = false
                    }
                }
            }
            else{
                appStateViewModel.activateToast(.FAIL,"Error"){
                    savingScreenShot = false
                }
            }
        }
#endif
        
    }
}
