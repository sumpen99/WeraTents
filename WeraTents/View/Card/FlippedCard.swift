//
//  FlippedCard.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-19.
//

import SwiftUI

struct FlippedCard:View {
    let image:Image
    let label:String?
    let modelId:String?
    let labelText:String
    let descriptionText:String
    let dateText:String
    let height:CGFloat
    let action:(String?,String?) -> Void
    @State var width:CGFloat = 0.0
    @State var angle: CGFloat = 0
    @State var lastAngle: CGFloat = 0
    @State var cardIsTapped:Bool = false
    
    var body: some View {
        ZStack{
            mainContent
            .frame(height: height)
            .offset(x:cardIsTapped ? 0.0 : 0,
                    y:cardIsTapped ? -50.0 : 0)
            cardButton
        }
   }
    
}

//MARK: - MAIN CONTENT
extension FlippedCard{
    var mainContent: some View {
        GeometryReader{ reader in
            sideContent
            .simultaneousGesture(dragGesture.simultaneously(with: tapGesture))
            .rotation3DEffect(.degrees(Double(angle)),
                                  axis: (x:0,y:1,z:0))
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
            .shadow(color:Color.lightGold,radius: 2.0)
            .onAppear{
                self.width = reader.size.width
            }
        }
    }
    
    @ViewBuilder
    var sideContent:some View{
        ZStack{
            if -90.0 <= self.angle && self.angle <= 90.0{
                frontSide
           }
            else{
                backSide
            }
        }
   
    }
}

//MARK: - CARD
extension FlippedCard{
    var frontSide:some View{
        ZStack {
            Color.lightBrown
            image
            .resizable()
            .scaledToFit()
            .hCenter()
        }
     }
    
    var backSide:some View{
        ZStack {
            Color.lightBrown
            cardText
        }
        .rotation3DEffect(.degrees(180), axis: (x:0,y:1,z:0))
     }
    
    var cardText: some View{
        VStack(spacing: V_SPACING_REG){
            Text(labelText)
            .font(.caption)
            .foregroundStyle(Color.materialDark)
            .bold()
            Text(descriptionText)
            .font(.caption2)
            .italic()
            .foregroundStyle(Color.materialDark)
            .vTop()
            Text(dateText)
            .font(.caption2)
            .foregroundStyle(Color.materialDark)
       }
       .padding()
    }
    
    @ViewBuilder
    var cardButton:some View{
        if cardIsTapped{
            Button(action: {
                action(label,modelId)
            }, label: {
                Text("Visa modell")
                .bold()
                .foregroundStyle(Color.white)
            })
            .frame(height: 35.0)
            .hCenter()
            .vBottom()
     }
    }
}
//MARK: - GESTURE
extension FlippedCard{
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
        .onChanged{ gesture in
            let theta = (atan2(gesture.location.x - self.width / 2.0,
                               self.height / 2.0  - gesture.location.y) - atan2(gesture.startLocation.x - self.width / 2.0, self.height / 2.0 - gesture.startLocation.y)).radToDeg()
            var newAngle = (theta + self.angle).truncatingRemainder(dividingBy: 360.0)
            if newAngle > 90.0{
                newAngle -= 360.0
            }
            self.angle = newAngle
            
        }
        .onEnded { gesture in
            if -90.0 <= self.angle && self.angle <= 90.0{
                self.angle = 0.0
             }
            else{
                self.angle = 180.0
            }
        }
      
    }
    
    var tapGesture: some Gesture {
        TapGesture()
        .onEnded({
            animateScale()
            debugLog(object: "tap elli tap")
        })
      
    }
}


//MARK: - FUNCTIONS
extension FlippedCard{
    
    func animateScale() -> Void{
        withAnimation{
            cardIsTapped.toggle()
        }
    }
}
