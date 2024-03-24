//
//  CatalogeButton.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-20.
//

import SwiftUI

struct CatalogeButton:View {
    @Binding var catalogeDb:String?
    let buttonText:String
    let frameWidth:CGFloat
    var disabledUnSelect:Bool = false
    let action:() -> Void
    var body: some View {
        content
        .shadow(color:isSelected() ? Color.lightGold : Color.clear,
                radius: CORNER_RADIUS_BRAND)
        .opacity(isSelected() ? 1.0 : 0.5)
    }
    
}

//MARK: - CONTENT
extension CatalogeButton{
    var content:some View{
        ZStack{
            Color.lightGold
            Text(buttonText)
            .foregroundStyle(Color.white)
            .bold()
            .shadow(color: Color.materialDarkest, radius: 5, x: 0, y: 5)
        }
        .onTapGesture {
            onAction()
        }
        .frame(width: calculatedWidth())
        .clipShape(RoundedRectangle(cornerRadius: CORNER_RADIUS_BRAND))
        .padding()
    }
}

//MARK: - FUNCTIONS
extension CatalogeButton{
    func calculatedWidth() -> CGFloat{
        let width = (frameWidth-V_SPACING_REG)/4
        return width < 0 ? 0 : width
    }
    
    func isSelected() -> Bool{
        if let catalogeDb = catalogeDb{
            return catalogeDb == buttonText
        }
        return false
    }
    
    var isDisabled: Bool{ disabledUnSelect && isSelected() }
    
    func onAction(){
        if isDisabled{ return }
        var selection:String? = nil
        if !isSelected(){
            selection = buttonText
        }
        withAnimation{
            catalogeDb = selection
        }
        action()
    }
}
