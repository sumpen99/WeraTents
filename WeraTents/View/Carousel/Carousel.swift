//
//  Carousel.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-23.
//

import SwiftUI

protocol CarouselItem:Identifiable{
    var id:Int { get }
    var img:Image { get }
    var title:String { get }
}

struct CarouselIndicators<T:CarouselItem>{
    var snappedItem = 0.0
    var draggingItem = 0.0
    var activeIndex: Int = 0
    var closest: CGFloat = 0.0
    var selectedItem:T? = nil
    var selectedIndex:Int = -1
}

struct Carousel<T:CarouselItem>:View {
    @Binding var isOpen:Bool
    @Binding var data:[T]
    let size:CGFloat
    let edge:Edge
    var onSelected:((T) -> Void)? = nil
    @State private var ind:CarouselIndicators<T> = CarouselIndicators<T>()
    
    // MARK: - GESTURES
    var carouselDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            ind.draggingItem = ind.snappedItem + value.translation.width / (size/2.0)
            ind.closest = round(ind.draggingItem).remainder(dividingBy: Double(data.count))
            setActiveIndex(ind.closest)
        }
        .onEnded { value in
            let inc = value.predictedEndTranslation.width/value.translation.width
            if value.predictedEndTranslation.width >= 0{
                spinCarousel(current: value.translation.width,inc:inc,iterations: 0){ (current,iterations) in
                    (current >= value.predictedEndTranslation.width)||iterations>50
                }
            }
            else{
                 spinCarousel(current: value.translation.width, inc: -inc,iterations: 0){ (current,iterations) in
                    (current <= value.predictedEndTranslation.width)||iterations>50
                }
            }
    
        }
    }
    
    var carouselLongTapGeasture:some Gesture{
        LongPressGesture()
            .onEnded(){ value in
                withAnimation{
                    onSelected?(data[ind.activeIndex])
                    isOpen.toggle()
                }
            }
    }
     
    var carouselTapGesture: some Gesture {
        TapGesture()
        .onEnded{
            withAnimation(.linear(duration: 0.25)){
                if userHasSelected{ self.ind.selectedItem = nil }
                else{
                    self.ind.selectedItem = data[ind.activeIndex]
                }
                
            }
        }
    }
    
    var dismissTapGesture: some Gesture {
        TapGesture()
        .onEnded{
            withAnimation(.linear(duration: 0.25)){
                if userHasSelected{ self.ind.selectedItem = nil }
                else{
                    isOpen.toggle()
                }
                
            }
        }
    }
     
    // MARK: - MAIN CONTENT
    var content:some View{
        ZStack{
            background
            carouselContent
        }
     }
    
    // MARK: - MAIN BODY
    var body: some View {
        content
        .transition(.move(edge: edge))
    }
}

// MARK: BACKGROUND
extension Carousel{
    var background:some View{
        ZStack{
            Color.white.opacity(0.7)
        }
        .ignoresSafeArea()
        .hCenter()
        .vTop()
        .gesture(dismissTapGesture)
    }
}

// MARK: - MAIN CAROUSEL CONTENT
extension Carousel{
    
    var carouselContent:some View{
        ZStack{
            carousel
            selectedCard
        }
        .background{
            Capsule()
                .fill(.white.opacity(0.7))
            .frame(width:size*2.75,height: size*1.5)
        }
        .zIndex(1)
    }
    
    var carousel:some View{
        ZStack {
            ForEach(data) { item in
                card(item)
            }
            currentlabel
        }
        .gesture(dragIsActive ? carouselDragGesture : nil)
    }
    
    func card(_ item:T)-> some View{
        ZStack {
            RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL)
            .fill(ind.selectedIndex == item.id ? Color.lightBrown : Color.white)
            item.img
            .resizable()
            .padding()
       }
        .simultaneousGesture(tapIsActive(item.id) ? carouselLongTapGeasture.simultaneously(with: carouselTapGesture) : nil)
        .frame(width: size, height: size)
        .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
        .opacity(1.0 - abs(distance(item.id)) * 0.3 )
        .offset(x: xOffset(item.id), y: 0)
        .zIndex(1.0 - abs(distance(item.id)) * 0.1)
    }
    
    var currentlabel:some View{
        Text(validLabel)
        .font(.callout)
        .foregroundStyle(Color.black .opacity(0.4))
        .italic()
        .vCenter()
        .hCenter()
        .offset(x:0,y:-(size/1.5))
        .padding(.top)
    }
     
}

    // MARK: - CAROUSEL BACKGROUND
extension Carousel{
    var carouselBackground:some View{
        Capsule()
        .fill(.white)
        .frame(width:size*2.75,height: size*1.5)
    
    }
}

    // MARK: - SELECTED CARD
extension Carousel{
    
    var selectedCardLabel:some View{
        Text(ind.selectedItem?.title ?? "")
        .padding(.top)
        .font(.title)
        .bold()
    }
    
    var selectedCardImage:some View{
        ind.selectedItem?.img
        .resizable()
        .scaledToFit()
    }
    
    var bottomButtons:some View{
        HStack{
            UrlButton(label:"Video",toVisit: "https://www.weratents.se/fortalt-husbil-husvagn/wera-vivaldi-570")
            UrlButton(label:"Hemsida",toVisit: "https://www.weratents.se/fortalt-husbil-husvagn/wera-vivaldi-570")
         }
    }
    
    var selectedCardContent:some View{
        VStack(spacing:0){
            selectedCardLabel
            List{
                selectedCardImage
                SectionFoldable(header: "Beskrivning",
                                content: Text(DUMMY_DESCRIPTION).font(.body).hLeading())
                .listRowBackground(Color.lightBrown)
                bottomButtons
            }
           .scrollContentBackground(.hidden)
        }
        .padding()
        
    }
    
    var selectedCardBackground:some View{
        RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL)
        .fill(Color.white)
    }
    
    @ViewBuilder
    var selectedCard:some View{
        if userHasSelected{
            ZStack{
                selectedCardBackground
                Indicator(cornerRadius:CORNER_RADIUS_CAROUSEL,
                          onDragFinnished: clearSelectedItem)
                selectedCardContent
            }
            .vCenter()
            .hCenter()
            .padding()
            .zIndex(1.0)
            .transition(.opacity.combined(with: .scale))
        }
        
    }
}

// MARK: - HELPER FUNCTIONS
extension Carousel{
    var userHasSelected:Bool{
        ind.selectedItem != nil
    }
    
    var dragIsActive:Bool{
        !userHasSelected
    }
    
    var validIndex:Int{
        if data.count > 0 && ind.activeIndex >= 0 && ind.activeIndex < data.count{
            return ind.activeIndex
        }
        return -1
    }
    
    var validLabel:String{
        return validIndex == -1 ? "" : data[validIndex].title
    }
    
    func spinCarousel(current:CGFloat,inc:CGFloat,iterations:Int,abort: @escaping (CGFloat,Int) -> Bool){
        if abort(current,iterations){
            ind.draggingItem = ind.closest
            ind.snappedItem = ind.draggingItem
            return
        }
        let newValue = current + inc
        let toMove = newValue / (size/2.0)
        ind.draggingItem = ind.snappedItem + toMove
        ind.closest = round(ind.draggingItem).remainder(dividingBy: Double(data.count))
        setActiveIndex(ind.closest)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            spinCarousel(current: newValue,inc:inc,iterations: iterations+1,abort: abort)
        })
        
    }
    
    func distance(_ item: Int) -> Double {
        return (ind.draggingItem - Double(item)).remainder(dividingBy: Double(data.count))
    }
    
    func xOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(data.count) * distance(item)
        return sin(angle) * size
    }
    
    func tapIsActive(_ id:Int) ->Bool{
        id == ind.activeIndex
    }
    
    func setActiveIndex(_ value:CGFloat){
        self.ind.activeIndex = data.count + Int(value)
        if self.ind.activeIndex > data.count || Int(value) >= 0 {
            self.ind.activeIndex = Int(value)
        }
    }
 
    func clearSelectedItem(){
        withAnimation{
            ind.selectedItem = nil
        }
    }
    
    func closeView(){
        withAnimation{
            isOpen.toggle()
        }
    }
}
