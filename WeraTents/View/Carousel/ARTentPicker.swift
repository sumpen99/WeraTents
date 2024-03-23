//
//  ArTentPicker.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-20.
//

import SwiftUI

struct TentPickerHelper{
    var selectedBrandCategory:String?
    var location = CGPoint()
    var offset:CGSize = CGSize()
    var flyAway:Bool = false
    var flyingCardValues:FlyingCardValues?
    
}

struct ARTentPicker:View {
    @Namespace var namespace
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @Binding var animationState:[Bool]
    @Binding var selectedTent:Tent?
    @GestureState private var startLocation: CGPoint? = nil
    @GestureState private var imageLocation: CGPoint? = nil
    @State var helper:TentPickerHelper = TentPickerHelper()
    var body: some View {
        content
            .animation(.easeIn(duration: 0.25),
                       value: animationState[ArAnimationState.SHOW_CAROUSEL.rawValue])
        .transition(.move(edge: .trailing))
    }
}

//MARK: - CONTENT
extension ARTentPicker{
    var content:some View{
        ZStack{
            background
            pickerMainContent
            .gesture(arPickerDragGesture)
            if animationState[ArAnimationState.SEND_PICKED_IMAGE.rawValue]{
                flyingCardContent
                .padding()
            }
        }
        .offset(helper.offset)
        .position(helper.location)
        .hCenter()
        .vCenter()
    }
    
    var background:some View{
        Color.white.opacity(0.005)
        .ignoresSafeArea()
        .gesture(arPickerTapGesture)
   }
    
    var pickerMainContent:some View{
        GeometryReader{ reader in
            VStack{
                headerBrandContent
                SplitLine(color: Color.lightGold)
                pickerContent(reader.size)
            }
            .background{
                Color.materialDarkest
            }
            .onAppear{
                helper.offset = reader.center()
            }
            .frame(width:reader.size.width,height: reader.size.height/1.5+MENU_HEIGHT_HEADER)
            .vCenter()
            .hCenter()
            .padding()
        }
    }
    
}

//MARK: - HEADER
extension ARTentPicker{
    var headerBrandContent:some View{
        ScrollviewLabelHeader(namespace: namespace,
                              namespaceName: "CURRENT_SELECTED_BRAND",
                              thickness: 2.0,
                              bindingList: firestoreViewModel.weraAsset?.brands ?? [],
                              selectedAnimation: .UNDERLINE,
                              menuHeight: MENU_HEIGHT_HEADER,
                              bindingLabel: $helper.selectedBrandCategory,
                              splittedLabel: true,
                              unselectedlabelColor: Color.gray)
        .onAppear{
            helper.selectedBrandCategory = firestoreViewModel.weraAsset?.brands?.first
        }
    }
}

//MARK: - PICKER
extension ARTentPicker{
    func pickerContent(_ size:CGSize) -> some View{
        ScrollView{
            LazyVGrid(columns: [GridItem(),GridItem()],
                      spacing: V_GRID_SPACING,
                      pinnedViews: .sectionHeaders){
                ForEach(firestoreViewModel.tentItemsBy(brand_category: helper.selectedBrandCategory),id:\.self){ tent in
                    ZStack{
                        FirestoreImage(iconImageUrl: tent.iconStorageIds?.first,
                                       imageType: .PICKER)
                        Text(tent.modelId)
                        .font(.footnote)
                        .bold()
                        .padding(5.0)
                        .background{
                            Rectangle().stroke(lineWidth:2.0)
                        }
                        .hCenter()
                        .vCenter()
                   }
                    .foregroundStyle(Color.white)
                    .onTapGesture(coordinateSpace: .global) { location in
                        if let selectedImageUrl = tent.iconStorageIds?.first{
                            helper.flyingCardValues = FlyingCardValues(
                                selectedImageUrl: selectedImageUrl,
                                startPosition: location,
                                startValues: CGSize(width: size.width/2.0, height: size.width/2.0),
                                endValues: CGSize(width: AR_SELECTED_IMAGE, height: AR_SELECTED_IMAGE))
                            animateChangedSelectionWithTent(tent)
                        }
                    }
                    
                }
            }
            .padding(.vertical)
        }
        .scrollIndicators(.hidden)
        .frame(width:size.width,height: size.height/1.5)
        .vTop()
    }
}

//MARK: - GESTURE
extension ARTentPicker{
    var arPickerTapGesture: some Gesture {
        TapGesture()
        .onEnded{
            animateOut()
        }
    }
    
    var arPickerDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            var newLocation = startLocation ?? helper.location
            newLocation.x += value.translation.width
            if newLocation.x <= 0{ return }
            animateToLocation(newLocation)
         }.updating($startLocation) { (value, startLocation, transaction) in
             startLocation = startLocation ?? helper.location
        }
        .onEnded{ value in
            if value.translation.width >= helper.offset.width/2.0{
                animateOut()
            }
            else{
                animateToLocation(CGPoint(x: 0.0, y: 0.0))
            }
        }
    }
    
    var arImageTapGesture: some Gesture {
        TapGesture()
        .onEnded{ location in
            debugLog(object: location)
        }
        
     }
}

//MARK: - FLYING-CARD
extension ARTentPicker{
    
    @ViewBuilder
    var flyingCardContent: some View {
        if let flyingCardvalues = helper.flyingCardValues{
            FlyingCard(animationState:$animationState,
                       flyingCardValues: flyingCardvalues)
        }
    }
    
}

//MARK: - FUNCTIONS
extension ARTentPicker{
    func animateOut(){
        withAnimation{
            animationState[ArAnimationState.SHOW_CAROUSEL.rawValue] = false
            helper.location = CGPoint(x: 0.0, y: 0.0)
        }
    }
    
    func animateToLocation(_ newLocation:CGPoint){
        withAnimation{
            helper.location = newLocation
        }
    }
    
    func animateChangedSelectionWithTent(_ tent:Tent){
        selectedTent = nil
        withAnimation{
            animationState[ArAnimationState.SHOW_SELECTED_TENT_IMAGE.rawValue] = false
            animationState[ArAnimationState.SEND_PICKED_IMAGE.rawValue] = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
            selectedTent = tent
        }
    }
    
}
