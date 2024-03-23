//
//  CatalogeSection.swift
//  WeraTents
//
//  Created by fredrik sundström on 2024-03-23.
//

import SwiftUI

struct CatalogeHelper{
    var selectedCataloge:String?
    var selectedBrand:String?
    var selectedModel:String?
 
    mutating func initFromNavigator(_ navigator:CatalogeNavigator){
        self.selectedCataloge = navigator.cataloge
        self.selectedBrand = navigator.brand
    }
    
    var noCurrentSelection: Bool{
        selectedCataloge == nil &&
        selectedBrand == nil &&
        selectedModel == nil
    }
    
    var onlyCataloge:Bool{
        selectedCataloge != nil &&
        selectedBrand == nil &&
        selectedModel == nil
    }
    
    var catalogeAndBrand:Bool{
        selectedBrand != nil &&
        selectedModel == nil
    }
}

struct CatalogeNavigator:Identifiable,Hashable{
    let id:String = shortId()
    let cataloge:String
    let brand:String
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
        
    static func == (lhs: CatalogeNavigator, rhs: CatalogeNavigator) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CatalogeSection:View {
    @EnvironmentObject var firestoreViewModel: FirestoreViewModel
    @Binding var helper:CatalogeHelper
    var body: some View {
        catalogeContent
    }
}

//MARK: - CATALOGE CONTENT
extension CatalogeSection{
    var catalogeContent:some View{
        VStack{
            GeometryReader{ reader in
                HStack(spacing: V_SPACING_REG){
                    catalogeButtons(reader.size.width)
                    .hCenter()
                }
            }
            .frame(height: HOME_BRAND_HEIGHT)
            .hCenter()
            .background{
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(Color.materialDark)
            }
            SplitLine(color: Color.lightGold)
        }
        .hCenter()
        
    }
    
    func catalogeButtons(_ maxWidth:CGFloat)-> some View{
        ForEach(firestoreViewModel.catalogeList(),id:\.self){ cataloge in
            CatalogeButton(catalogeDb:$helper.selectedCataloge,
                           buttonText: cataloge,
                           frameWidth: maxWidth,
                           action:{
                withAnimation{
                    helper.selectedBrand = nil
                    helper.selectedModel = nil
                }
            })
        }
     }
}
