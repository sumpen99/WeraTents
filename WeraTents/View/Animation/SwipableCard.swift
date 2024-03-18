//
//  SwipableCard.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-17.
//

import SwiftUI

enum SwipeDirection{
    case UP
    case RIGHT
    case LEFT
    case DOWN
    case CENTER
    
    var asset: (name:String,color:Color){
        switch self{
        case .UP:       return (name:"hand.thumbsup.circle",color:Color.green)
        case .RIGHT:    return (name:"hand.thumbsup.circle",color:Color.green)
        case .LEFT:     return (name:"hand.thumbsdown.circle",color:Color.yellow)
        case .DOWN:     return (name:"hand.thumbsdown.circle",color:Color.yellow)
        case .CENTER:   return (name:"",color:Color.clear)
        }
    }
}

enum SwipePlane{
    case VERTICAL
    case HORIZONTAL
}

struct SafeAreaBounds{
    let minX = -50.0
    let minY = -50.0
    let maxX = 50.0
    let maxY = 50.0
    
    func swipeDirection(_ size:CGSize) -> SwipeDirection{
        let swipePlane:SwipePlane = abs(size.width) > abs(size.height) ? .HORIZONTAL : .VERTICAL
        if (minX < size.width && size.width < maxX) &&
            (minY < size.height && maxY > size.height){
            return .CENTER
        }
        switch swipePlane{
        case .HORIZONTAL:
            return size.width < 0 ? .LEFT : .RIGHT
        case .VERTICAL:
            return size.height < 0 ? .UP : .DOWN
        }
    }
}

struct SwipableCard: View {
    @Binding var isShown:Bool
    let uiImage:UIImage?
    let action:(Bool) -> Void
    @GestureState private var startLocation: CGPoint? = nil
    @State var location = CGPoint()
    @State var offset:CGSize = CGSize()
    @State var swipeDirection:SwipeDirection = .CENTER
    let safeArea = SafeAreaBounds()
    
    var body: some View {
        content
        .transition(.scale.combined(with: .opacity))
    }
    
    @ViewBuilder
    var content:some View{
        if let uiImage = uiImage{
            GeometryReader{ reader in
                ZStack{
                    Color.white
                    capturedImage(uiImage)
                    swipeActionImage(reader.min())
                    swipeHelpInstruction(reader.min())
                }
                .onAppear{
                    offset = reader.center()
                }
                .offset(offset)
                .position(location)
                .gesture(dragGesture)
                .vCenter()
                .hCenter()
            }
            
        }
    }
}

//MARK: - IMAGES
extension SwipableCard{
    
    func capturedImage(_ uiImage:UIImage) -> some View{
        Image(uiImage: uiImage)
        .resizable()
        .scaledToFit()
        .padding()
        .zIndex(0.5)
    }
    
    @ViewBuilder
    func swipeActionImage(_ size:CGFloat) -> some View{
        if swipeDirection != .CENTER{
            let asset = swipeDirection.asset
            ZStack{
                Image(systemName: asset.name)
                .resizable()
                .foregroundStyle(asset.color)
            }
            .zIndex(1.0)
            .frame(width: size/3.0,height: size/3.0)
            .vCenter()
            .hCenter()
         }
    }
    
    @ViewBuilder
    func swipeHelpInstruction(_ size:CGFloat) -> some View{
        if swipeDirection == .CENTER{
            HStack{
                Image(systemName: "arrowshape.turn.up.backward")
                    .resizable()
                    .frame(width: size/6.0,height: size/6.0)
                    .foregroundStyle(Color.materialDark.opacity(0.5))
                Text("Swipa spara eller ta bort")
                .foregroundStyle(Color.white)
                .font(.title3)
                .bold()
                .padding()
                .background{
                    Color.materialDark.opacity(0.5)
                    .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
               }
                .hCenter()
                Image(systemName: "arrowshape.turn.up.forward")
                    .resizable()
                    .frame(width: size/6.0,height: size/6.0)
                    .foregroundStyle(Color.materialDark.opacity(0.5))
            }
            .zIndex(0.8)
            .vCenter()
            .hCenter()
        }
    }
}

//MARK: - GESTURE
extension SwipableCard{
    var dragGesture: some Gesture {
        DragGesture()
        .onChanged { value in
            var newLocation = startLocation ?? location
            newLocation.x += value.translation.width
            newLocation.y += value.translation.height
            location = newLocation
            swipeDirection = safeArea.swipeDirection(value.translation)
         }.updating($startLocation) { (value, startLocation, transaction) in
            startLocation = startLocation ?? location
        }
        .onEnded{ value in
            swipeDirection = safeArea.swipeDirection(value.translation)
            if swipeDirection == .CENTER{
                location = CGPoint(x: 0, y: 0)
                return
            }
            else{
                var newOffset = offset
                switch swipeDirection{
                case .UP:       newOffset.height *= -2.0
                case .DOWN:     newOffset.height *= 4.0
                case .RIGHT:    newOffset.width  *= 4.0
                case .LEFT:     newOffset.width  *= -2.0
                default:break
                }
                withAnimation(Animation.easeOut(duration: 0.25)) {
                    self.offset = newOffset
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                    isShown.toggle()
                    action(swipeDirection == .UP || swipeDirection == .RIGHT)
                }
            }
            
        }
    }
    
}
