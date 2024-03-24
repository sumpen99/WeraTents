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
    let ignoreTapGesture: Bool
    @State var width:CGFloat = 0.0
    @State var angle: CGFloat = 0
    @State var cardIsTapped:Bool = false
    @State var textInput:String = ""
    
    var body: some View {
        mainContent
        .frame(height: height)
    }
    
}

//MARK: - MAIN CONTENT
extension FlippedCard{
    var mainContent: some View {
        GeometryReader{ reader in
            sideContent
            .simultaneousGesture(dragGesture.simultaneously(with:ignoreTapGesture ? nil : tapGesture))
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
    
    var cardText: some View{
        VStack(spacing: V_SPACING_REG){
            Text(labelText)
            .font(.caption)
            .foregroundStyle(Color.materialDark)
            .bold()
            TextEditorWithPlaceholder(text: $textInput)
            //.font(.custom("HelveticaNeue", size: 13))
            //.lineSpacing(5)
            /*Text(descriptionText)
            .font(.caption2)
            .italic()
            .foregroundStyle(Color.materialDark)
            .vTop()*/
            Text(dateText)
            .font(.caption2)
            .foregroundStyle(Color.materialDark)
            .bold()
       }
        .padding(.vertical)
        .padding(.horizontal,5.0)
    }
    
}
//MARK: - GESTURE
extension FlippedCard{
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
        .onChanged{ gesture in
            let theta = (atan2(gesture.location.x - self.width / 2.0,
                               self.height / 2.0  - gesture.location.y) - 
                         atan2(gesture.startLocation.x - self.width / 2.0,
                               self.height / 2.0 - gesture.startLocation.y))
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
    
    var tapGesture: some Gesture {
        TapGesture()
        .onEnded({
            animateScale()
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
    
    func itIsFrontside() -> Bool{
        return  (-90.0 < self.angle && self.angle <= 90.0) ||
                (-360 < self.angle && self.angle <= -270)  ||
                (270 < self.angle && self.angle <= 360)
    }
}


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
                    .frame(minHeight: 150, maxHeight: 300)
                    .opacity(text.isEmpty ? 0.85 : 1)
                    .font(.callout)
                    .scrollContentBackground(.hidden)
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_BRAND))
    }
}
