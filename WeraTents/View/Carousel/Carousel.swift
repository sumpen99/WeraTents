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
   
    
    var userHasSelected:Bool{
        selectedItem != nil
    }
    
    var dragIsActive:Bool{
        !userHasSelected
    }
    
    func tapIsActive(_ id:Int) ->Bool{
        id == activeIndex
    }
    
// MARK: - GESTRURES
    var simpleDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            draggingItem = snappedItem + value.translation.width / (size/2.0)
            closest = round(draggingItem).remainder(dividingBy: Double(data.count))
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
            self.activeIndex = data.count + Int(draggingItem)
            if self.activeIndex > data.count || Int(draggingItem) >= 0 {
                self.activeIndex = Int(draggingItem)
            }
        }
    }
    
    var simpleTapGesture: some Gesture {
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
     
// MARK: - CAROUSEL CARD
    func cardLabel(_ name:String) -> some View{
        Text(name)
        .font(.callout)
        .bold()
        .foregroundStyle(Color.black)
        .padding([.top,.leading,.trailing])
        .vCenter()
        .hCenter()
    }
    
    func cardImage(_ img:Image) -> some View{
        img
        .resizable()
        .padding()
    }
    
    func card(_ item:T)-> some View{
        ZStack {
            RoundedRectangle(cornerRadius: 18)
            .fill(Color.white)
            cardImage(item.img)
       }
        .gesture(tapIsActive(item.id) ? simpleTapGesture : nil)
        .frame(width: size, height: size)
        .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
        .opacity(1.0 - abs(distance(item.id)) * 0.3 )
        .offset(x: xOffset(item.id), y: 0)
        .zIndex(1.0 - abs(distance(item.id)) * 0.1)
    }
    
// MARK: - SELECTED CARD
    @ViewBuilder
    var selectedCard:some View{
        if userHasSelected{
            ZStack{
                RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                cardImage(selectedItem!.img)
            }
            .frame(width:size*2.75,height: size*2.75)
            .zIndex(1.0)
            .transition(.opacity.combined(with: .scale))
        }
        
    }
// MARK: - CAROUSEL BACKGROUND
    var carouselBackground:some View{
        Capsule()
        .fill(.white)
        .frame(width:size*2.75,height: size*1.5)
   }
    
// MARK: - CAROUSEL
    var carousel:some View{
        ZStack {
            ForEach(data) { item in
                card(item)
            }
        }
        .gesture(dragIsActive ? simpleDragGesture : nil)
    }
    
// MARK: - MAIN CONTENT
    var content:some View{
        ZStack{
            Color.lightGreen.opacity(0.8)
            carousel
            selectedCard
        }
        .background{
            carouselBackground
        }
        .vCenter()
        .hCenter()
     }
    
// MARK: - MAIN BODY
    var body: some View {
        content
        .gesture(userHasSelected ? simpleTapGesture : nil)
        .ignoresSafeArea(.all)
        .transition(.move(edge: edge))
    }
}

// MARK: -- HELPER FUNCTIONS
extension Carousel{
    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(data.count))
    }
    
    func xOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(data.count) * distance(item)
        return sin(angle) * size
    }
}
