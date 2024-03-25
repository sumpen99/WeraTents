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
    let deleteCard:() -> Void
    @State var width:CGFloat = 0.0
    @State var angle: CGFloat = 0.0
    @State var textInput:String = ""
    
    var body: some View {
        mainContent
        .frame(height: HOME_CAPTURED_HEIGHT)
        .onAppear{
            textInput = descriptionText
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
            Color.lightBrown
            if itIsFrontside(){
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
        image
        .resizable()
        .clipped()
     }
    
    var backSide:some View{
        cardText
        .rotation3DEffect(.degrees(180), axis: (x:0,y:1,z:0))
     }
    
    @ViewBuilder
    var cardText: some View{
        VStack(spacing: V_SPACING_REG){
            Text(labelText)
            .font(.caption)
            .foregroundStyle(Color.materialDark)
            .bold()
            TextEditorWithPlaceholder(text: $textInput)
            bottomRow
            
            
       }
        .padding(.vertical)
        .padding(.horizontal,10.0)
    }
    
    var bottomRow:some View{
        HStack{
            Text(dateText)
            .font(.caption)
            .foregroundStyle(Color.materialDark)
            .bold()
            .hLeading()
            Spacer()
            if descriptionText != textInput{
                Button(action: saveAndReset, label: {
                    Text("Spara")
                    .font(.callout)
                    .foregroundStyle(Color.blue)
                    .bold()
                })
                .hTrailing()
            }
            else{
                Button(action: deleteCard, label: {
                    Text("Radera")
                    .font(.callout)
                    .foregroundStyle(Color.blue)
                    .bold()
                })
                .hTrailing()
            }
        }
    }
    
}
//MARK: - GESTURE
extension FlippedCard{
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
        .onChanged{ gesture in
            let theta = (atan2(gesture.location.x - self.width / 2.0,
                               HOME_CAPTURED_HEIGHT / 2.0  - gesture.location.y) -
                         atan2(gesture.startLocation.x - self.width / 2.0,
                               HOME_CAPTURED_HEIGHT / 2.0 - gesture.startLocation.y))
                .radToDeg()
            self.angle = (theta + self.angle).truncatingRemainder(dividingBy: 360.0)
        }
        .onEnded { gesture in
            if itIsFrontside(){
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
        
    func itIsFrontside() -> Bool{
        return  (-90.0 < self.angle && self.angle <= 90.0) ||
                (-360 <= self.angle && self.angle <= -270)  ||
                (270 < self.angle && self.angle <= 360)
    }
    
    func saveAndReset(){
        withAnimation{
            descriptionText = textInput
        }
        saveNewComment(textInput)
    }
    
    
}

//MARK: - TEXT-EDITOR-WITH-PLACEHOLDER
struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color(uiColor: .tertiaryLabel).opacity(0.2)
            if text.isEmpty {
               VStack {
                    Text("Lägg till en kommentar...")
                        .padding(.top, 10)
                        .padding(.leading, 6)
                        .opacity(0.6)
                        .font(.callout)
                    Spacer()
                }
            }
            
            VStack {
                TextEditor(text: $text)
                    .vTop()
                    .opacity(text.isEmpty ? 0.85 : 1)
                    .font(.callout)
                    .scrollContentBackground(.hidden)
                Spacer()
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_BRAND))
    }
}
