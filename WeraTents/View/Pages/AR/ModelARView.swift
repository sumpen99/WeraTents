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
    case SAVING_SCREEN_SHOT
    case DELAY_CAPTURE_BUTTON
    case SHOW_TAKEN_PICTURE
}

struct ArHelper{
    var animationState:[Bool] = Array(repeating: false, count: ArAnimationState.allCases.count)
    var lastImageData:Data?
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
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom){
            bottomButtons
        }
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            backButton
        }
        .overlay{
            if helper.stateOf(animation: .SAVING_SCREEN_SHOT){
                ScreenShotAnimation(arAnimationState:$helper.animationState,
                                    imageData: helper.lastImageData)
            }
            else if helper.stateOf(animation: .SHOW_TAKEN_PICTURE){
                SwipableCard(isShown:$helper.animationState[ArAnimationState.SHOW_TAKEN_PICTURE.rawValue],
                             data: helper.lastImageData,
                             action:actionAfterCapturedImage)
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
        }
    }
    
    var arContent:some View{
         ARViewContainer(arViewCoordinator: arViewCoordinator)
         .task {
             arViewCoordinator.run()
         }
    }
    var backButton:some View{
        BackButtonAction(action: navigateBack)
        .hLeading()
        .padding()
    }
    
}

//MARK: - CAROUSEL
extension ModelARView{
    @ViewBuilder
    var carouselContent:some View{
        if helper.stateOf(animation: .SHOW_CAROUSEL){
            ZStack{
                GeometryReader{ reader in
                    Carousel(isOpen:$helper.animationState[ArAnimationState.SHOW_CAROUSEL.rawValue],
                             data: $firestoreViewModel.tentAssets,
                             size: min(reader.size.width,reader.size.height)/3,
                             onSelected:onSelectedItem)
                }
            }
            .animation(.linear(duration: 0.25),
                       value: helper.animationState[ArAnimationState.SHOW_CAROUSEL.rawValue])
            .transition(.move(edge: .trailing))
        }
    }
}

//MARK: - BOTTOM BUTTONS
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
        Button(action:placeModel,
               label:{
            roundedImage("plus",font:.largeTitle,
                         scale:.large,
                         radius: 70.0,
                         foreground: Color.darkGreen,
                         background: Color.white,
                         thicknes:2.0)
        })
    }
    
    var removeModelButton:some View{
        Button(action:removeModel,
               label:{
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
            withAnimation{
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
    
    @ViewBuilder
    var centerButton: some View{
        if arViewCoordinator.activeAddButton{
            placeModelButton
        }
        else if arViewCoordinator.activeCaptureButton{
            captureImageButton
        }
     }
    
    @ViewBuilder
    var leadingButton: some View{
        if arViewCoordinator.activeRemoveButton{
            removeModelButton
            .transition(.opacity)
        }
      }
    
    var interactButtons:some View{
        ZStack{
            leadingButton.hLeading()
            centerButton.hCenter()
            showCarouselButton.hTrailing()
        }
        .frame(height: 70.0)
    }
    
    var bottomButtons:some View{
        interactButtons
        .padding([.leading,.trailing])
    }
}

//MARK: - FUNCTIONS CAPTURED IMAGES
extension ModelARView{
    func captureImage(){
        helper.setStateOf(animations: [.FLASH_SCREEN,.SAVING_SCREEN_SHOT,.DELAY_CAPTURE_BUTTON],
                          values: [true,true,true])
        arViewCoordinator.captureSnapshot(){ data in
            if let data = data{
                helper.lastImageData = data
                helper.setStateOf(animation: .SEND_CARD, value: true)
            }
            else{
                appStateViewModel.activateToast(.FAIL,"Misslyckades med att fånga skärmen!"){
                    helper.setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                }
            }
        }
    }
    
    func actionAfterCapturedImage(didSave:Bool) -> Void{
        if didSave{
            saveCapturedImage()
        }
        helper.lastImageData = nil
        helper.setStateOf(animation: .DELAY_CAPTURE_BUTTON, value: false)
    }
    
    func saveCapturedImage(){
        if let data = helper.lastImageData{
            let managedObjectContext = PersistenceController.shared.container.viewContext
            let model = ScreenshotModel(context:managedObjectContext)
            model.buildWithName(arViewCoordinator.selectedTentMeta)
            let image = ScreenshotImage(context:managedObjectContext)
            image.id = model.id
            image.data = data
            model.image = image
            do{
                try PersistenceController.saveContext()
                appStateViewModel.activateToast(.BASE,"Sparat!")
            }
            catch{
                appStateViewModel.activateToast(.FAIL,"Misslyckades med att spara!")
            }
        }
    }
}

//MARK: - FUNCTIONS ARVIEW-COORDINATOR
extension ModelARView{
    
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
                appStateViewModel?.activateToast(.FAIL,"Ett fel uppstod!"){
                    helper.setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                }
            }
        }
    }
    
    func onSelectedItem(tent:TentMeta) ->Void{
        arViewCoordinator.newSelectedTent(tent)
    }
    
}
