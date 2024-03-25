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
    case SHOW_SELECTED_TENT_IMAGE
    case SEND_PICKED_IMAGE
    case LOADING_USDZ_MODEL
    case SHOW_SHORT_DESCRIPTION
}

struct ArHelper{
    var animationState:[Bool] = Array(repeating: false, count: ArAnimationState.allCases.count)
    var selectedTent:Tent?
    var dontShowInfoTextAgain:Bool = false
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
    @StateObject private var cameraManager: CameraManger
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var appStateViewModel: AppStateViewModel
    @State var helper:ArHelper = ArHelper()
    init() {
        self._arViewCoordinator = StateObject(wrappedValue: ARViewCoordinator())
        self._sceneViewCoordinator = StateObject(wrappedValue: SceneViewCoordinator())
        self._cameraManager = StateObject(wrappedValue: CameraManger())
    }
            
    var body: some View{
        mainContent
        .onChange(of: helper.selectedTent,initial: false){ oldValue,newValue in
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
            if helper.stateOf(animation: .SAVING_SCREEN_SHOT){
                ScreenShotAnimation(arAnimationState:$helper.animationState)
            }
            else if helper.stateOf(animation: .SHOW_TAKEN_PICTURE){
                SwipableCard(isShown:$helper.animationState[ArAnimationState.SHOW_TAKEN_PICTURE.rawValue],
                             action:actionAfterCapturedImage)
            }
            else if helper.stateOf(animation: .SHOW_CAROUSEL){
                pickerContent
            }
            else if helper.stateOf(animation: .LOADING_USDZ_MODEL){
                spinnerContent
            }
            else if helper.stateOf(animation: .SHOW_SHORT_DESCRIPTION){
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
                       value: helper.animationState[ArAnimationState.LOADING_USDZ_MODEL.rawValue])
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
                       value: helper.animationState[ArAnimationState.SHOW_SHORT_DESCRIPTION.rawValue])
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
            Toggle(isOn: $helper.dontShowInfoTextAgain) {
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
        if helper.stateOf(animation: .SHOW_CAROUSEL){
            ARTentPicker(animationState:$helper.animationState,
                         selectedTent: $helper.selectedTent)
         }
    }
}

//MARK: - FLYING-IMAGE
extension ModelARView{
    @ViewBuilder
    var selectedtentImage:some View{
        if let tent = helper.selectedTent{
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
            if helper.stateOf(animation: .SAVING_SCREEN_SHOT){
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
        .disabled(helper.stateOf(animation: .DELAY_CAPTURE_BUTTON))
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
        helper.setStateOf(animations: [.FLASH_SCREEN,.SAVING_SCREEN_SHOT,.DELAY_CAPTURE_BUTTON],
                          values: [true,true,true])
        arViewCoordinator.captureSnapshot(){ uiImage in
            DispatchQueue.global(qos: .userInteractive).async {
                if let uiImage = uiImage{
                    ServiceManager.writeImageToCache(fileName: TEMP_SCREENSHOT_NAME,
                                                     uiImage: uiImage,
                                                     folder: .SCREEN_SHOT){ result in
                        helper.setStateOf(animation: .SEND_CARD, value: true)
                    }
                }
                else{
                    appStateViewModel.activateToast(.FAIL,"Misslyckades med att fånga skärmen!"){
                        helper.setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                    }
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
        DispatchQueue.global(qos: .userInteractive).async {
            scaledImageWith(compressionQuality: 1.0,
                            ofSize: CGSize(width: 2040.0,height: 250.0),
                            trimmed: false){ imageData in
                if let imageData = imageData{
                    let managedObjectContext = PersistenceController.shared.container.viewContext
                    let model = ScreenshotModel(context:managedObjectContext)
                    model.buildWithName(arViewCoordinator.selectedTent)
                    
                    let image = ScreenshotImage(context:managedObjectContext)
                    image.data = imageData
                    model.image = image
                    do{
                        try PersistenceController.saveContext()
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
    }
    
    func resetAndNotifyUserWithToastState(_ state:ToastState,_ message:String){
        appStateViewModel.activateToast(state,message)
        clearTempFromImage()
        helper.setStateOf(animation: .DELAY_CAPTURE_BUTTON, value: false)
    }
    
    func resetWithoutNotifyUserWithToastState(){
        clearTempFromImage()
        helper.setStateOf(animation: .DELAY_CAPTURE_BUTTON, value: false)
    }
    
    func clearTempFromImage(){
        ServiceManager.removefileFromFolder(folder: .SCREEN_SHOT,
                                            fileName: TEMP_SCREENSHOT_NAME,
                                            ext: "png")
    }
    
    func resetCarousel(){
        withAnimation{
            helper.animationState[ArAnimationState.SHOW_CAROUSEL.rawValue].toggle()
        }
    }
   
    func animateStateOf(_ state:ArAnimationState,with value:Bool){
        withAnimation{
            helper.animationState[state.rawValue] = value
        }
    }
    
}

//MARK: - SCALE CAPTURED IMAGE
extension ModelARView{
    
    func scaledImageWith(compressionQuality toStore:CGFloat,
                         ofSize maxSize:CGSize,
                         trimmed trimImage:Bool,completion:@escaping (Data?) -> Void){
            var jpegData:Data?
            if let url = ServiceManager.fileExistInside(folder: .SCREEN_SHOT,
                                                        fileName: TEMP_SCREENSHOT_NAME,
                                                         ext: "png"),
               let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data),
               let scaleFactor = calculateScaleFactor(ofSize:maxSize,
                                                      imageWidth:uiImage.size.width,
                                                      imageHeight: uiImage.size.height,
                                                      trimImage:trimImage),
               let thumb = uiImage.preparingThumbnail(of: scaleFactor){
                jpegData = thumb.jpegData(compressionQuality: toStore)
            }
            completion(jpegData)
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
                    helper.setStateOf(animation: .SAVING_SCREEN_SHOT, value: false)
                }
            }
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
