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
    @State var descriptionText:String
    let dateText:String
    let saveNewComment:(String) -> Void
    let tapGestureAction:(CGPoint) -> Void
    @State var width:CGFloat = 0.0
    @State var angle: CGFloat = 0.0
    @State var textInput:String = ""
    
    var body: some View {
        mainContent
        .frame(height: CAPTURED_HEIGHT_SHOW)
        .onAppear{
            textInput = descriptionText
        }
        .onTapGesture(coordinateSpace: .global) { location in
            executeTapAction(location)
        }
    }
    
}

//MARK: - MAIN CONTENT
extension FlippedCard{
    var mainContent: some View {
        GeometryReader{ reader in
            sideContent
            .gesture(dragGesture)
            .rotation3DEffect(.degrees(Double(angle)),
                                  axis: (x:0,y:1,z:0))
            .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_CAROUSEL))
            .onAppear{
                self.width = reader.size.width
            }
        }
    }
    
    @ViewBuilder
    var sideContent:some View{
        ZStack{
            if itIsFrontside{
                Color.clear
                frontSide
           }
            else{
                Color.lightBrown
                backSide
            }
        }
     }
    
}

//MARK: - CARD
extension FlippedCard{
    var frontSide:some View{
        image
        .resizable()
        .clipped()
     }
    
    var backSide:some View{
        cardText
        .rotation3DEffect(.degrees(180), axis: (x:0,y:1,z:0))
     }
    
    var cardText: some View{
        VStack(spacing: V_SPACING_REG){
            baseText(labelText)
            TextEditorWithPlaceholder(text: $textInput,
                                      placeholderText: "Lägg till en kommentar...")
            bottomRow
       }
        .padding(.vertical)
        .padding(.horizontal,10.0)
    }
    
    func baseText(_ text:String) -> some View{
        Text(text)
        .font(.caption)
        .foregroundStyle(Color.materialDark)
        .bold()
    }
    
    var bottomRow:some View{
        baseText(dateText)
        .hLeading()
    }
    
}
//MARK: - GESTURE
extension FlippedCard{
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
        .onChanged{ gesture in
            let theta = (atan2(gesture.location.x - self.width / 2.0,
                               CAPTURED_HEIGHT_SHOW / 2.0  - gesture.location.y) -
                         atan2(gesture.startLocation.x - self.width / 2.0,
                               CAPTURED_HEIGHT_SHOW / 2.0 - gesture.startLocation.y))
                .radToDeg()
            self.angle = (theta + self.angle).truncatingRemainder(dividingBy: 360.0)
        }
        .onEnded { gesture in
            if itIsFrontside{
                saveIfWeHaveNewChanges()
                self.angle = 0.0
            }
            else{
                self.angle = 180.0
            }
        }
    }
     
}


//MARK: - FUNCTIONS
extension FlippedCard{
        
    var itIsFrontside: Bool{
        return  (self.angle == 0.0) ||
                (-90.0 < self.angle && self.angle <= 90.0) ||
                (-360 <= self.angle && self.angle <= -270)  ||
                (270 < self.angle && self.angle <= 360)
    }
    
    
    func executeTapAction(_ location:CGPoint){
        if itIsFrontside{
            tapGestureAction(location)
        }
    }
    
    func saveIfWeHaveNewChanges(){
        if descriptionText != textInput{
            saveAndReset()
        }
    }
    
    func saveAndReset(){
        descriptionText = textInput
        saveNewComment(textInput)
    }
    
    
}
