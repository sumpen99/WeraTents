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
    @State private var snappedItem = 0.0
    @State private var draggingItem = 0.0
    @State var activeIndex: Int = 0
   
// MARK: - GESTRURES
    var simpleDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            draggingItem = snappedItem + value.translation.width / (size/2.0)
        }
        .onEnded { value in
            withAnimation {
                draggingItem = snappedItem + value.predictedEndTranslation.width / (size/2.0)
                draggingItem = round(draggingItem).remainder(dividingBy: Double(data.count))
                snappedItem = draggingItem
                
                self.activeIndex = data.count + Int(draggingItem)
                if self.activeIndex > data.count || Int(draggingItem) >= 0 {
                    self.activeIndex = Int(draggingItem)
                }
            }
        }
    }
    
    var simpleTapGesture: some Gesture {
        TapGesture()
        .onEnded(){ tap in
            debugLog(object: "\(activeIndex)")
            
        }
    }
    
// MARK: - CAROUSEL
    var carousel:some View{
        ZStack {
            ForEach(data) { item in
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                    item.img.resizable()
                        .padding()
                }
                .frame(width: size, height: size)
                .scaleEffect(1.0 - abs(distance(item.id)) * 0.2 )
                .opacity(1.0 - abs(distance(item.id)) * 0.3 )
                .offset(x: xOffset(item.id), y: 0)
                .zIndex(1.0 - abs(distance(item.id)) * 0.1)
            }
        }
        
    }
    
    var body: some View {
        carousel
        .simultaneousGesture(simpleDragGesture.simultaneously(with: simpleTapGesture))
        .vCenter()
        .hCenter()
    }
}

extension Carousel{
    func distance(_ item: Int) -> Double {
        return (draggingItem - Double(item)).remainder(dividingBy: Double(data.count))
    }
    
    func xOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(data.count) * distance(item)
        return sin(angle) * size
    }
}
