//
//  Carousel2.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-02-27.
//
import SwiftUI

struct HomeCarousel<T:CarouselItem>:View {
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Binding var data:[T]
    let width:CGFloat
    let edge:Edge
    @State private var ind:CarouselIndicators<T> = CarouselIndicators<T>()
    
    // MARK: - GESTURES
    var carouselDragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            ind.draggingItem = ind.snappedItem + value.translation.width / (width/2.0)
            ind.closest = round(ind.draggingItem).remainder(dividingBy: Double(data.count))
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
        carousel
            
    }
}


// MARK: - MAIN CAROUSEL CONTENT
extension HomeCarousel{
   
    var carousel:some View{
        ZStack {
            ForEach(data) { item in
                card(item)
            }
        }
        .gesture(carouselDragGesture)
    }
    
    func card(_ item:T)-> some View{
        ZStack {
            Color.lightBrown
            HStack{
                VStack{
                    Text(item.name).font(.caption)
                        .foregroundStyle(Color.materialDark).bold()
                    Text(item.shortDescription).font(.caption2).lineLimit(3).vCenter()
                        .italic().foregroundStyle(Color.materialDark)
                    Button(action: navigate, label: {
                        Text("Se mer").bold()
                    })
                    .buttonStyle(.borderedProminent)
                }
                .padding()
               .hCenter()
                ZStack{
                    item.img
                    .resizable()
                }
                
            }
       }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
        .frame(width: width, height: HOME_CAROUSEL_HEIGHT)
        .scaleEffect(1.0 - abs(distance(item.index)) * 0.2 )
        .offset(x: xOffset(item.index) * 1.63, y: 0)
        .opacity(1.0 - abs(distance(item.index)) * 0.3 )
        .zIndex(1.0 - abs(distance(item.index)) * 0.1)
    }
     
}

// MARK: - HELPER FUNCTIONS
extension HomeCarousel{
    
    var validIndex:Int{
        if data.count > 0 && ind.activeIndex >= 0 && ind.activeIndex < data.count{
            return ind.activeIndex
        }
        return -1
    }
    
    func navigate(){
        let index = validIndex
        if index != -1{
            navigationViewModel.appendToPathWith(data[index])
        }
    }
   
    func spinCarousel(current:CGFloat,inc:CGFloat,iterations:Int,abort: @escaping (CGFloat,Int) -> Bool){
        if abort(current,iterations){
            ind.draggingItem = ind.closest
            ind.snappedItem = ind.draggingItem
            return
        }
        let newValue = current + inc
        let toMove = newValue / (width/2.0)
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
        return sin(angle) * width
    }
    
    func yOffset(_ item: Int) -> Double {
        let angle = Double.pi * 2 / Double(data.count) * distance(item)
        return cos(angle) * width
    }
    
    func setActiveIndex(_ value:CGFloat){
        self.ind.activeIndex = data.count + Int(value)
        if self.ind.activeIndex > data.count || Int(value) >= 0 {
            self.ind.activeIndex = Int(value)
        }
    }
 
}

