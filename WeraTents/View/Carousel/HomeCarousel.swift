//
//  Carousel2.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-27.
//
import SwiftUI

struct CarouselHelper{
    var snappedItem = 0.0
    var draggingItem = 0.0
    var activeIndex: Int = 0
    var closest: CGFloat = 0.0
    var selectedItem:TentItem? = nil
    var selectedIndex:Int = -1
    var cardIsTappedScale:CGFloat = 1.0
     
    mutating func resetTap(){
        cardIsTappedScale = 1.0
    }
}

struct HomeCarousel:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    let cardWidth:CGFloat
    let brandWidth:CGFloat
    let edge:Edge
    @State private var ind:CarouselHelper = CarouselHelper()
    
    // MARK: - GESTURES
    var carouselDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            ind.draggingItem = ind.snappedItem + value.translation.width / (cardWidth/2.0)
            ind.closest = round(ind.draggingItem).remainder(dividingBy: Double(dataCount))
            setActiveIndex(ind.closest)
        }
        .onEnded { value in
            withAnimation(.easeIn){
                ind.draggingItem = ind.closest
                ind.snappedItem = ind.draggingItem
            }
         }
    }
    
    // MARK: - MAIN BODY
    var body: some View {
        VStack{
            carousel
            brandContent
        }
        .onAppear{
            ind.resetTap()
        }
        
    }
}

// MARK: - CAROUSEL CONTENT
extension HomeCarousel{
   
    var carousel:some View{
        ZStack {
            ForEach(firestoreViewModel.tentAssets) { item in
                card(item)
            }
        }
        .gesture(carouselDragGesture)
     }
    
    func card(_ item:TentItem)-> some View{
        ZStack {
            Color.lightBrown
            HStack(spacing:0){
                VStack(spacing:0){
                    cardText(name: item.name, shortDesc: item.shortDescription)
                    PressedCardButton(cardIsTappedScale: $ind.cardIsTappedScale,
                                      scaleFactor: 0.8,
                                      imageLabel: "hand.point.up.left",
                                      action: navigate)
                }
                .padding(.top)
                item.img.resizable()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
        .frame(width: cardWidth, height: HOME_CAROUSEL_HEIGHT)
        .shadow(color:Color.lightGold,radius: 2.0)
        .scaleEffect(cardIsOnTop(item.index) ? ind.cardIsTappedScale :
                     1.0 - abs(distance(item.index)) * 0.2 )
        .offset(x: xOffset(item.index) * 1.63, y: 0)
        .opacity(1.0 - abs(distance(item.index)) * 0.3 )
        .zIndex(1.0 - abs(distance(item.index)) * 0.1)
    }
    
    func cardText(name:String,shortDesc:String) -> some View{
        VStack(spacing: V_SPACING_REG){
            Text(name)
            .font(.caption)
            .foregroundStyle(Color.materialDark)
            .bold()
            Text(shortDesc).font(.caption2)
            .italic()
            .foregroundStyle(Color.materialDark)
       }
        .vTop()
        .padding(.horizontal)
        .hCenter()
    }
    
}

// MARK: - BRAND CONTENT
extension HomeCarousel{
    var brandContent:some View{
        ScrollView(.horizontal){
            HStack(spacing: V_SPACING_REG){
                brandButtons
            }
        }
        .frame(height: HOME_BRAND_HEIGHT)
        .hCenter()
    }
    
    var brandButtons: some View{
        ForEach(firestoreViewModel.brandAsset.keys,id:\.self){ brand in
            DropShadowButton(buttonText: brand,frameWidth: calculatedWidth, action: {navigateToBrand(brand)})
        }
    }
}

// MARK: - HELPER FUNCTIONS
extension HomeCarousel{
    
    var dataCount:Int{
        firestoreViewModel.assetCount
    }
    
    var validIndex: Int?{
        if dataCount > 0 && ind.activeIndex >= 0 && ind.activeIndex < dataCount{
            return ind.activeIndex
        }
        return nil
    }
    
    var calculatedWidth: CGFloat{
        let itemCount = 3.0
        let padding = CGFloat(itemCount-1)*V_SPACING_REG
        let width = (brandWidth-padding)/(itemCount+1)
        return width < 0 ? 0 : width
    }
    
    func validIndex(of number:Int) -> Int?{
        if dataCount > 0 && number >= 0 && number < dataCount{
            return number
        }
        return nil
    }
    
    func navigate(){
        if let index = validIndex{
            navigationViewModel.appendToPathWith(firestoreViewModel.tentAssets[index])
        }
     }
    
    func navigateToBrand(_ brand:String){
        if let index = validIndex{
            if brand == firestoreViewModel.tentAssets[index].label { return }
            if let itemIndex = firestoreViewModel.tentAssets.firstIndex(where: {$0.label == brand }),
               let navToIndex = validIndex(of:itemIndex){
                setNewIndex(navToIndex)
            }
        }
    }
   
    func spinCarousel(current:CGFloat,inc:CGFloat,iterations:Int,abort: @escaping (CGFloat,Int) -> Bool){
        if abort(current,iterations){
            ind.draggingItem = ind.closest
            ind.snappedItem = ind.draggingItem
            return
        }
        let newValue = current + inc
        let toMove = newValue / (cardWidth/2.0)
        ind.draggingItem = ind.snappedItem + toMove
        ind.closest = round(ind.draggingItem).remainder(dividingBy: Double(dataCount))
        setActiveIndex(ind.closest)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            spinCarousel(current: newValue,inc:inc,iterations: iterations+1,abort: abort)
        })
        
    }
    
    func cardIsOnTop(_ index:Int) -> Bool{
        return index == self.ind.activeIndex
    }
     
    func distance(_ item: Int) -> Double {
        return (ind.draggingItem - Double(item)).remainder(dividingBy: Double(dataCount))
    }
    
    func xOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(dataCount) * distance(item)
        return sin(angle) * cardWidth
    }
    
    func yOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(dataCount) * distance(item)
        return cos(angle) * cardWidth
    }
    
    func setActiveIndex(_ value:CGFloat){
        self.ind.activeIndex = dataCount + Int(value)
        if self.ind.activeIndex > dataCount || Int(value) >= 0 {
            self.ind.activeIndex = Int(value)
        }
    }
    
    func setNewIndex(_ value:Int){
        if self.ind.activeIndex == value { return }
        withAnimation{
            self.ind.activeIndex = value
            self.ind.draggingItem = Double(value)
            self.ind.snappedItem = Double(value)
        }
    }
 
}

