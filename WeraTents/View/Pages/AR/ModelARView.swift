//
//  ARView.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-20.
//

import SwiftUI

enum ArAnimationState:Int,CaseIterable{
    case FLASH_SCREEN
    case SEND_CARD
    case SHOW_CAROUSEL
    case TOGGLE_CAPTURED_IMAGES
    case SAVING_SCREEN_SHOT
    case DELAY_CAPTURE_BUTTON
    case HAS_CAPTURED_IMAGES
}

struct ArHelper{
    var animationState:[Bool] = Array(repeating: false, count: ArAnimationState.allCases.count)
    var capturedImageCount:Int = 0
    var imageData:[Data] = []
    func stateOf(animation state:ArAnimationState) -> Bool{
        return animationState[state.rawValue]
    }
    
    mutating func setStateOf(animation state:ArAnimationState,value:Bool){
        animationState[state.rawValue] = value
    }
    
    mutating func setStateOf(animations states:[ArAnimationState],values:[Bool]){
        for i in 0..<states.count{
            animationState[states[i].rawValue] = values[i]
        }
    }
}

struct ModelARView: View {
    @EnvironmentObject var firestoreViewModel:FirestoreViewModel
    @StateObject private var arViewCoordinator: ARViewCoordinator
    @StateObject private var sceneViewCoordinator: SceneViewCoordinator
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    @State var helper:ArHelper = ArHelper()
    init() {
        self._arViewCoordinator = StateObject(wrappedValue: ARViewCoordinator())
        self._sceneViewCoordinator = StateObject(wrappedValue: SceneViewCoordinator())
    }
            
    var body: some View{
        mainContent
        .onChange(of: helper.animationState[ArAnimationState.SAVING_SCREEN_SHOT.rawValue],
                  initial: false){ oldValue,newValue in
            if oldValue{
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
                    helper.setStateOf(animation: .DELAY_CAPTURE_BUTTON, value: false)
                }
            }
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
            if helper.stateOf(animation: .SAVING_SCREEN_SHOT){
                ScreenShotAnimation(arAnimationState:$helper.animationState,
                                    imageData: helper.imageData.last)
            }
        }
        .overlay{
            carouselContent
        }
        
    }
}


//MARK: - MAIN CONTENT
extension ModelARView{
    
    var mainContent:some View{
        ZStack{
            Color.background
            arContent
            ZStack{
                ForEach(helper.imageData.indices,id:\.self){ index in
                    i(helper.imageData[index],index:index)
                }
            }
            .hCenter()
            .vCenter()
        }
    }
    
    @ViewBuilder
    func i(_ data:Data,index:Int) -> some View{
        if let uiImage = UIImage(data: data){
            ZStack{
                Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
            }
            .zIndex(1.0 - CGFloat(index) * 0.1)
            .scaleEffect(1.0-(0.1*CGFloat(index)))
            .position(CGPoint(x:0,y:-CGFloat(index)*10.0))
            .frame(width:80.0,height:80.0)
            //.rotation3DEffect(.degrees(1), axis: (x:1.0,y:0.0,z:0.0))
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
    
}

//MARK: - CAROUSEL
extension ModelARView{
    var carouselContent:some View{
        GeometryReader{ reader in
            ZStack{
                if helper.stateOf(animation: .SHOW_CAROUSEL){
                    Carousel(isOpen:$helper.animationState[ArAnimationState.SHOW_CAROUSEL.rawValue],
                             data: $firestoreViewModel.tentAssets,
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
            if helper.stateOf(animation: .SAVING_SCREEN_SHOT){
                ProgressView()
                .foregroundStyle(Color.white)
                .hCenter()
            }
            else{
                roundedImage("camera.metering.center.weighted.average",font:.largeTitle,
                             scale:.large,
                             radius: 70.0,
                             foreground: Color.darkGreen,
                             background: Color.white,
                             thicknes:2.0)
            }
        })
        .disabled(helper.stateOf(animation: .DELAY_CAPTURE_BUTTON))
    }
    
    var placeModelButton:some View{
        Button(action: {
            placeModel()
        },label:   {
            roundedImage("plus",font:.largeTitle,
                         scale:.large,
                         radius: 70.0,
                         foreground: Color.darkGreen,
                         background: Color.white,
                         thicknes:2.0)
        })
    }
    
    var removeModelButton:some View{
        Button(action: {
            removeModel()
        },label:{
            roundedImage("minus",
                         font:.title,
                         scale:.medium,
                         radius: 40.0,
                         foreground: Color.red,
                         background: Color.white,
                         thicknes:2.0)
        })
    }
    
    var showCarouselButton:some View{
        Button(action: {
            if !firestoreViewModel.hasTents{ return }
            withAnimation(.easeInOut(duration: 0.45)){
                helper.animationState[ArAnimationState.SHOW_CAROUSEL.rawValue].toggle()
            }
            
        },label:{
            roundedImage("tent",
                         font:.title,
                         scale:.medium,
                         radius: 60.0,
                         foreground: Color.darkGreen,
                         background: Color.white,
                         thicknes:2.0)
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
     }
    
    func leadingButton() -> some View{
        ZStack{
            if arViewCoordinator.activeRemoveButton{
                removeModelButton
            }
        }
      }
    
    var interactButtons:some View{
        ZStack{
            leadingButton().hLeading()
            centerButton().hCenter()
            showCarouselButton.hTrailing()
        }
        .transition(.opacity)
    }
    
    var bottomButtons:some View{
        interactButtons
        .padding([.leading,.trailing])
    }
}

//MARK: - TOPBAR
extension ModelARView{
    
    var topButtons:some View{
        HStack{
            BackButtonAction(action: navigateBack)
            navigateToCapturedImagesButton
        }
        .hLeading()
        .padding()
    }
    
    @ViewBuilder
    var navigateToCapturedImagesButton:some View{
        if helper.stateOf(animation: .HAS_CAPTURED_IMAGES){
            Button(action: navigateToCapturedImages , label: {
                buttonImage("photo.stack.fill",font: TOP_BAR_FONT,foreground: Color.white)
                //.rotationEffect(Angle(degrees: 45.0))
                //.badge(count: $capturedImageCount)
            })
            .hTrailing()
            .symbolEffect(.bounce.down, value: helper.stateOf(animation: .TOGGLE_CAPTURED_IMAGES))
        }
        
    }
}

//MARK: - FUNCTIONS
extension ModelARView{
    
    func navigateToCapturedImages(){
        arViewCoordinator.pause()
        arViewCoordinator.action(.REMOVE_3D_MODEL){ result in
            navigationViewModel.appendToPathWith(ModelRoute.ROUTE_CAPTURED_IMAGES)
        }
    }
    
    func navigateBack(){
        releaseMemory()
        navigationViewModel.popPath()
    }
    
    func releaseMemory(){
        arViewCoordinator.kill()
     }
     
    func removeModel(){
        arViewCoordinator.action(.REMOVE_3D_MODEL)
    }
    
    func placeModel(){
        arViewCoordinator.action(.PLACE_3D_MODEL){ [weak appStateViewModel] result in
            if !result{
                appStateViewModel?.activateToast(.FAIL,"Fel uppstod!"){
                    helper.setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                }
            }
        }
    }
    
    func onSelectedItem(tent:TentMeta) ->Void{
        arViewCoordinator.newSelectedTent(tent)
    }
    
    func captureImage(){
        helper.setStateOf(animations: [.FLASH_SCREEN,.SAVING_SCREEN_SHOT,.DELAY_CAPTURE_BUTTON],
                          values: [true,true,true])
        let managedObjectContext = PersistenceController.shared.container.viewContext
        arViewCoordinator.captureSnapshot(){ data in
            if let data = data{
                let model = ScreenshotModel(context:managedObjectContext)
                model.buildWithName(arViewCoordinator.selectedTentMeta)
                let image = ScreenshotImage(context:managedObjectContext)
                image.id = model.id
                image.data = data
                model.image = image
                do{
                    try PersistenceController.saveContext()
                    helper.imageData.append(data)
                    helper.setStateOf(animation: .SEND_CARD, value: true)
                }
                catch{
                    appStateViewModel.activateToast(.FAIL,"Error"){
                        helper.setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                    }
                }
            }
            else{
                appStateViewModel.activateToast(.FAIL,"Error"){
                    helper.setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                }
            }
        }
       
    }
}
