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
    case SHOW_SELECTED_TENT_IMAGE
    case SEND_PICKED_IMAGE
    case LOADING_USDZ_MODEL
    case SHOW_SHORT_DESCRIPTION
    case DONT_SHOW_INFO_TEXT_AGAIN
}
var CURRENT_TAKEN_SCREEN_SHOT_IMAGE:UIImage?

struct ModelARView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var firestoreViewModel:FirestoreViewModel
    @StateObject private var arViewCoordinator: ARViewCoordinator
    @StateObject private var cameraManager: CameraManger
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    @State var animationState:[Bool] = Array(repeating: false, count:ArAnimationState.allCases.count)
    @State var selectedTent:Tent?
    init() {
        self._arViewCoordinator = StateObject(wrappedValue: ARViewCoordinator())
        self._cameraManager = StateObject(wrappedValue: CameraManger())
   }
            
    var body: some View{
        mainContent
        .onChange(of: selectedTent,initial: false){ oldValue,newValue in
            resetArCoordinatorWith(newTent: newValue)
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom){
            if cameraManager.permission.isAuthorized{
                bottomButtons.vBottom()
            }
        }
        .toolbar(.hidden)
        .safeAreaInset(edge: .top){
            topBar
        }
        .overlay{
            if stateOf(animation: .SAVING_SCREEN_SHOT){
                ScreenShotAnimation(arAnimationState:$animationState,
                                    action:actionAfterCapturedImage)
            }
            else if stateOf(animation: .SHOW_CAROUSEL){
                pickerContent
            }
            else if stateOf(animation: .LOADING_USDZ_MODEL){
                spinnerContent
            }
            else if stateOf(animation: .SHOW_SHORT_DESCRIPTION){
                shortInfoOnHowToDo
            }
        }
    }
    
}


//MARK: - MAIN CONTENT
extension ModelARView{
     
    var mainContent:some View{
        ZStack{
            Color.darkestGreen
            if cameraManager.permission.isAuthorized{
                ARViewContainer(arViewCoordinator: arViewCoordinator)
                .task{
                    arViewCoordinator.run()
                }
            }
            else if cameraManager.permission.status != .notDetermined && ServiceManager.canOpenSettingsUrl(){
                missingPermissionView
            }
         }
        .task{
            await cameraManager.setUpCaptureSession()
        }
    }
    
    var missingPermissionView:some View{
        VStack(spacing:V_SPACING_REG){
            Text("Saknade rättigheter.").bold()
            Text("Augmented reality behöver tillgång till kameran. Nuvarande status ger oss ej möjlighet till det.Om ni vill ändra på det kan ni nu, eller senare, göra så direkt i system inställningarna.")
            Button("Inställningar", action: {
                ServiceManager.openPrivacySettings()
            })
            .background{
                Color.white
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.materialDarkest)
            .padding()
            
        }
        .padding()
        .background{
            Color.darkestGreen
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
        .vCenter()
        .hCenter()
        .foregroundStyle(Color.white)
        .padding()
    }
    
}

//MARK: - LOADING SPINNER
extension ModelARView{
    var spinnerContent:some View{
        GeometryReader{ reader in
            ZStack{
                Color.section
                SpinnerAnimation(timer:SpinnerTimer.noDelayedStartTime(),
                                 frameSize:CGSize(width:reader.size.width*0.5,
                                                  height: reader.size.height*0.25),
                                 text:"Laddar 3d-model...",
                                 textColor:Color.white)
            }
            .frame(width: reader.size.width*0.75,height:reader.size.height/4.0)
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
            .animation(.easeIn(duration: 0.25),
                       value: animationState[ArAnimationState.LOADING_USDZ_MODEL.rawValue])
            .transition(.scale.combined(with: .opacity))
            .ignoresSafeArea(.all)
            .vCenter()
            .hCenter()
        }
    }
}

//MARK: - SHORT INFO
extension ModelARView{
    var shortInfoOnHowToDo:some View{
        GeometryReader{ reader in
            ZStack{
                Color.darkestGreen
                shortInfoContent(reader.size.width)
             }
            .frame(height:reader.size.height/4.0)
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
            .animation(.easeIn(duration: 1.25),
                       value: animationState[ArAnimationState.SHOW_SHORT_DESCRIPTION.rawValue])
            .transition(.scale.combined(with: .opacity))
            .ignoresSafeArea(.all)
            .vCenter()
            .hCenter()
            .padding(.horizontal)
        }
    }
    
    func shortInfoContent(_ size:CGFloat) -> some View{
        VStack{
            shortInfotext
            shortInfoButtons
        }
        .padding()
        .vCenter()
        .hCenter()
    }
    
    var shortInfotext:some View{
        Text("När fokusrutan i mitten av skärmen hittar ett horisontalt plan går det att placera ut modellen. Ibland behöver telefonen ta in miljön från lite olika vinklar. Använd sedan fingrarna för att rotera och flytta runt. Tältet kommer röra sig på planet så om det hamnar fel är det bättre att ta bort och placera ut igen.")
        .foregroundStyle(Color.white)
        .font(.footnote)
        .bold()
        .vCenter()
    }
    
    var shortInfoButtons: some View{
        HStack{
            Toggle(isOn: $animationState[ArAnimationState.DONT_SHOW_INFO_TEXT_AGAIN.rawValue]) {
                Text("Visa inte igen")
            }
            .toggleStyle(CheckboxStyle(alignLabelLeft: true,
                                       labelColor: Color.white,
                                       checkBoxColor: Color.lightGold))
            .hLeading()
            Button(action: { animateStateOf(.SHOW_SHORT_DESCRIPTION, with: false)}, label: {
                Text("Ok, jag förstår")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(Color.white)
            })
            .background{
                Color.lightGold
            }
            .buttonStyle(.bordered)
       }
   }
}

//MARK: - TOP-BAR
extension ModelARView{
    var topBar:some View{
        ZStack{
            BackButtonAction(action: navigateBack)
            .hLeading()
            .vTop()
            selectedtentImage
            .hCenter()
            .vTop()
        }
        .hLeading()
        .padding(.vertical)
   }
}

//MARK: - PICKER
extension ModelARView{
    @ViewBuilder
    var pickerContent:some View{
        if stateOf(animation: .SHOW_CAROUSEL){
            ARTentPicker(animationState:$animationState,
                         selectedTent: $selectedTent)
         }
    }
}

//MARK: - FLYING-IMAGE
extension ModelARView{
    @ViewBuilder
    var selectedtentImage:some View{
        if let tent = selectedTent{
            FirestoreImage(iconImageUrl: tent.iconStorageIds?.first,
                           imageType: .PICKER)
            .frame(width:AR_SELECTED_IMAGE,height: AR_SELECTED_IMAGE)
            .offset(y:-AR_SELECTED_IMAGE/4.0)
        }
    }
}

//MARK: - BOTTOM BUTTONS
extension ModelARView{
    func roundedImage(_ name:String,
                      font:Font,
                      scale:Image.Scale,
                      radius:CGFloat,
                      foreground:Color,
                      background:Color,
                      outerBackground:Color,
                      thicknes:CGFloat) -> some View{
            Image(systemName: name)
            .font(font)
            .bold()
            .foregroundStyle(foreground)
            .imageScale(scale)
            .padding()
            .background(
                Circle()
                .fill(background)
            )
            .padding(2)
            .background(
                Circle()
                    .fill(outerBackground)
            )
             
    }
    
    var captureImageButton:some View{
        Button(action: captureImage, label: {
            if stateOf(animation: .SAVING_SCREEN_SHOT){
                ProgressView()
                .foregroundStyle(Color.white)
                .hCenter()
            }
            else{
                roundedImage("camera.metering.center.weighted.average",
                             font:.largeTitle,
                             scale:.large,
                             radius: 90.0,
                             foreground: Color.darkGreen,
                             background: Color.darkestGreen,
                             outerBackground: Color.darkGreen,
                             thicknes:2.0)
            }
        })
        .disabled(stateOf(animation: .DELAY_CAPTURE_BUTTON))
    }
    
    var placeModelButton:some View{
        Button(action:placeModel,
               label:{
            roundedImage("plus",
                         font:.largeTitle,
                         scale:.large,
                         radius: 90.0,
                         foreground: Color.darkGreen,
                         background: Color.darkestGreen,
                         outerBackground: Color.darkGreen,
                         thicknes:2.0)
        })
    }
    
    var removeModelButton:some View{
        Button(action:removeModel,
               label:{
            roundedImage("minus.circle",
                         font:.title,
                         scale:.medium,
                         radius: 80.0,
                         foreground: Color.red,
                         background: Color.darkestGreen,
                         outerBackground: Color.red,
                         thicknes:2.0)
        })
    }
    
    var showCarouselButton:some View{
        Button(action: resetCarousel,label:{
            roundedImage("tent",
                         font:.title,
                         scale:.medium,
                         radius: 80.0,
                         foreground: Color.lightGold,
                         background: Color.darkestGreen,
                         outerBackground: Color.lightGold,
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
            centerButton.hCenter().padding(.bottom)
            showCarouselButton.hTrailing()
        }
        .frame(height: 90.0)
    }
    
    var bottomButtons:some View{
        interactButtons
        .padding([.leading,.trailing])
    }
}

//MARK: - FUNCTIONS CAPTURED IMAGES
extension ModelARView{
    func captureImage(){
        setStateOf(animations: [.FLASH_SCREEN,.SAVING_SCREEN_SHOT,.DELAY_CAPTURE_BUTTON],
                          values: [true,true,true])
        arViewCoordinator.captureSnapshot(){ uiImage in
            if let uiImage = uiImage{
                CURRENT_TAKEN_SCREEN_SHOT_IMAGE = uiImage
                setStateOf(animation: .SEND_CARD, value: true)
            }
            else{
                appStateViewModel.activateToast(.FAIL,"Misslyckades med att fånga skärmen!"){
                    setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                }
            }
            
        }
    }
    
    func actionAfterCapturedImage(didSave:Bool) -> Void{
        if didSave , #available(iOS 15.0, *){
            saveCapturedImage()
        }
        else if didSave{
            resetAndNotifyUserWithToastState(.FAIL,"Kräver version >= IOS 15")
        }
        else{
            resetWithoutNotifyUserWithToastState()
        }
    }
    
    
    func saveCapturedImage(){
        let model = ScreenshotModel(context:managedObjectContext)
        let image =  ScreenshotImage(context:managedObjectContext)
        DispatchQueue.global(qos: .userInteractive).async { [weak arViewCoordinator] in
            if let imageData = scaledImageWith(compressionQuality: 1.0,
                            ofSize: CGSize(width: 2040.0,height: HOME_CAPTURED_HEIGHT),
                            trimmed: false),
               let arViewCoordinator = arViewCoordinator{
                model.buildWithName(arViewCoordinator.selectedTent)
                image.data = imageData
                model.image = image
                    do{
                        try managedObjectContext.save()
                        resetAndNotifyUserWithToastState(.SUCCESS,"Sparat!")
                    }
                    catch{
                        resetAndNotifyUserWithToastState(.FAIL,"Misslyckades med att spara!")
                    }
            }
            else{
                resetAndNotifyUserWithToastState(.FAIL,"Misslyckades med att spara!")
            }
        }
    }
    
    
    func resetAndNotifyUserWithToastState(_ state:ToastState,_ message:String){
        appStateViewModel.activateToast(state,message)
        clearTempFromImage()
        setStateOf(animation: .DELAY_CAPTURE_BUTTON, value: false)
    }
    
    func resetWithoutNotifyUserWithToastState(){
        clearTempFromImage()
        setStateOf(animation: .DELAY_CAPTURE_BUTTON, value: false)
    }
    
    func clearTempFromImage(){
        CURRENT_TAKEN_SCREEN_SHOT_IMAGE = nil
    }
    
    func resetCarousel(){
        withAnimation{
            animationState[ArAnimationState.SHOW_CAROUSEL.rawValue].toggle()
        }
    }
   
    func animateStateOf(_ state:ArAnimationState,with value:Bool){
        withAnimation{
            animationState[state.rawValue] = value
        }
    }
    
}

//MARK: - SCALE CAPTURED IMAGE
extension ModelARView{
    
    func scaledImageWith(compressionQuality toStore:CGFloat,
                         ofSize maxSize:CGSize,
                         trimmed trimImage:Bool) ->Data?{
            var jpegData:Data?
            if let uiImage = CURRENT_TAKEN_SCREEN_SHOT_IMAGE,
               let scaleFactor = calculateScaleFactor(ofSize:maxSize,
                                                      imageWidth:uiImage.size.width,
                                                      imageHeight: uiImage.size.height,
                                                      trimImage:trimImage),
               let thumb = uiImage.preparingThumbnail(of: scaleFactor){
                jpegData = thumb.jpegData(compressionQuality: toStore)
            }
            return jpegData
    }
    
    func calculateScaleFactor(ofSize maxSize:CGSize,
                              imageWidth origWidth:Double,
                              imageHeight origHeight:Double,
                              trimImage:Bool) -> CGSize?{
        let maxWidth = maxSize.width,maxHeight = maxSize.height
        var newWidth = origWidth,newHeight = origHeight
        var trimWidth = 0.0, trimHeight = 0.0

        if origWidth > maxWidth || origHeight > maxHeight{
            if trimImage{
                let factor:Double = max(maxWidth / origWidth,maxHeight / origHeight)
                newHeight =  ceil(origHeight * factor)
                trimWidth = newWidth - maxWidth
                trimHeight = newHeight - maxHeight
            }
            else{
                let factor = min(maxWidth / origWidth,maxHeight / origHeight)
                newWidth = ceil(origWidth * factor)
                newHeight = ceil(origHeight * factor)
            }
        }
        
        return CGSize(width: newWidth - trimWidth, height: newHeight - trimHeight)
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
                    setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                }
            }
        }
    }
    
    func stateOf(animation state:ArAnimationState) -> Bool{
        return animationState[state.rawValue]
    }
    
    func setStateOf(animation state:ArAnimationState,value:Bool){
        animationState[state.rawValue] = value
    }
    
    func setStateOf(animations states:[ArAnimationState],values:[Bool]){
        for i in 0..<states.count{
            animationState[states[i].rawValue] = values[i]
        }
    }
    
    func resetArCoordinatorWith(newTent:Tent?){
        arViewCoordinator.removeSelectedTent()
        if let newTent = newTent,
           let fileName = newTent.modelStorageIds?.first{
            
            animateStateOf(.LOADING_USDZ_MODEL, with: true)
            firestoreViewModel.loadTentModelData(fileName){ [weak arViewCoordinator] url in
                if let url = url{
                    arViewCoordinator?.newSelectedTent(newTent, modelURL: url)
                    animateStateOf(.LOADING_USDZ_MODEL, with: false)
                    animateStateOf(.SHOW_SHORT_DESCRIPTION, with: true)
                }
                else{
                    appStateViewModel.activateToast(.FAIL,"Modellen kunde inte laddas korrekt.")
                    animateStateOf(.LOADING_USDZ_MODEL, with: false)
                }
                
            }
            
        }
    }
    
    
}
