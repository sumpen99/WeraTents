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

struct Carousel<T:CarouselItem>:View {
    @Binding var data:[T]
    let size:CGFloat
    let edge:Edge
    let onTap:((T) -> Void)? = nil
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0
    @State var activeIndex: Int = 0
    @State var closest: CGFloat = 0.0
    @State var selectedItem:T? = nil
   
    // MARK: - GESTRURES
    var carouselDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            draggingItem = snappedItem + value.translation.width / (size/2.0)
            closest = round(draggingItem).remainder(dividingBy: Double(data.count))
            setActiveIndex(closest)
        }
        .onEnded { value in
            let predMax = size*2
            let pred = value.predictedEndTranslation.width
            if pred > predMax||pred < -predMax{
                draggingItem = closest
            }
            else{
                draggingItem = snappedItem + pred / (size/2.0)
                draggingItem = round(draggingItem).remainder(dividingBy: Double(data.count))
            }
            snappedItem = draggingItem
            setActiveIndex(draggingItem)
        }
    }
    
    var carouselTapGesture: some Gesture {
        TapGesture()
        .onEnded{
            withAnimation(.linear(duration: 0.25)){
                if userHasSelected{ self.selectedItem = nil }
                else{
                    self.selectedItem = data[activeIndex]
                }
                
            }
        }
    }
    
    // MARK: - MAIN CONTENT
    var content:some View{
        ZStack{
            Color.lightGreen.opacity(0.7)
            carousel
            selectedCard
        }
        .background{
            Capsule()
            .fill(.white)
            .frame(width:size*2.75,height: size*1.5)
        }
        .vCenter()
        .hCenter()
     }
    
    // MARK: - MAIN BODY
    var body: some View {
        content
        //.gesture(userHasSelected ? simpleTapGesture : nil)
        .transition(.move(edge: edge))
    }
}

    // MARK: - MAIN CAROUSEL CONTENT
extension Carousel{
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
            .fill(Color.white)
            item.img
            .resizable()
            .padding()
       }
        .gesture(tapIsActive(item.id) ? carouselTapGesture : nil)
        .frame(width: size, height: size)
        .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
        .opacity(1.0 - abs(distance(item.id)) * 0.3 )
        .offset(x: xOffset(item.id), y: 0)
        .zIndex(1.0 - abs(distance(item.id)) * 0.1)
    }
    
    var currentlabel:some View{
        Text(validLabel)
        .font(.callout)
        .bold()
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
        Text(selectedItem?.title ?? "")
        .padding(.top)
        .font(.title)
        .bold()
    }
    
    var selectedCardImage:some View{
        selectedItem?.img
        .resizable()
        .scaledToFit()
    }
    
    var bottomButtons:some View{
        HStack{
            
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
        selectedItem != nil
    }
    
    var dragIsActive:Bool{
        !userHasSelected
    }
    
    var validIndex:Int{
        if data.count > 0 && activeIndex >= 0 && activeIndex < data.count{
            return activeIndex
        }
        return -1
    }
    
    var validLabel:String{
        return validIndex == -1 ? "" : data[validIndex].title
    }
    
    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(data.count))
    }
    
    func xOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(data.count) * distance(item)
        return sin(angle) * size
    }
    
    func tapIsActive(_ id:Int) ->Bool{
        id == activeIndex
    }
    
    func setActiveIndex(_ value:CGFloat){
        self.activeIndex = data.count + Int(value)
        if self.activeIndex > data.count || Int(value) >= 0 {
            self.activeIndex = Int(value)
        }
    }
    
    func clearSelectedItem(){
        withAnimation{
            selectedItem = nil
        }
    }
}
